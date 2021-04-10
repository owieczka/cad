/*=======================================*\
#  _                    _             _   #
# | |    __ _ _ __ ___ | |__       _-(")- #
# | |   / _` | '_ ` _ \| '_ \    `%%%%%   #
# | |__| (_| | | | |_| | |_) | _  // \\   #
# |_____\__,_|_| |_| |_|_.__/_| |__  ___  #
#                  | |   / _` | '_ \/ __| #
#                  | |__| (_| | |_) \__ \ #
#  2021-04-04      |_____\__,_|_.__/|___/ #
#                                         #
\*=======================================*/
//*/

//https://www.bearingworks.com/bearing-sizes/

/*
         height/2
   <--------------->
    h1   h2   h3    h4
   <--><----><--><----->
             ______ _ _ 
            /      |   ^
           /           |
          /        |   | r3
    _____/_ _ _ _ _ _ _|_ _
   /_ _ _ _ _ _ _ _ _ _|_ _ ^ _ _ _
   |                   |    | r2  ^ r1
   |_ _ _ _ _ _ _ _|_ _v_ _ v _ _ v
//*/


/*
   CROSS SECTION
              outer_radius
   |<------------------------------------>|
                                inner_radius
                                 |<------>|
 
   .-------.   .-----.   .------.         |
   |        | |       | |        |        
   |        | |       | |        |        |
   |       .' |       | '.       |        
   |     .' .'         '. '.     |        |
   |   .' .'             '. '.   |        
   |   | |                 | |   |        |
   |   | |                 | |   |        
   |   | |                 | |   |        |
   
   |<->|    wall_thickiness  |<->|
       |-|
        gap
//*/



boolean_op_margin = 1;

module base_shape(r,r0,r1,r2,r3,h1,h2,h3,h4) {
  polygon([[r,h1],[r0,0],[r1,0],[r2,h1],[r2,h1+h2],[r3,h1+h2+h3],[r3,h1+h2+h3+h4+h4],[r2,h1+h2+h3+h4+h4+h3],[r2,h1+h2+h3+h4+h4+h3+h2],[r1,h1+h2+h3+h4+h4+h3+h2+h1],[r0,h1+h2+h3+h4+h4+h3+h2+h1],[r,h1+h2+h3+h4+h4+h3+h2]]);
}

//base_shape(0,0.5,1.5,2,4,1,1,1,1);

module roller_cross_section(r1,r2,r3,h1,h2,h3,h4) {
  base_shape(0,0,r1,r2,r3,h1,h2,h3,h4);
}

module outer_ring_cross_section(r,r0,r1,r2,r3,h1,h2,h3,h4) {
  base_shape(r,r0,r1,r2,r3,h1,h2,h3,h4);
}

module inner_ring_cross_section(r,r0,r1,r2,r3,h1,h2,h3,h4) {
  base_shape(r,r0,r1,r2,r3,h1,h2,h3,h4);
}

module rotate_extrude_cond(angle=360,condition=true, convexity=2) {
  if(condition) {
    rotate_extrude(angle=angle, convexity = convexity) children();
  } else {
    children();
  }
}

module populate_rollers(step_angle, radius, condition=true) {
  if(condition) {
    for(i=[0:step_angle:360]) {
      rotate(a=i,v=[0,0,1]) {
        translate(v=[radius,0,0]) {
          children();
        }
      }
    }
  } else {
    translate(v=[radius,0,0]) {
      rotate(a=000,v=[0,1,0]) children();
      rotate(a=180,v=[0,1,0]) children();
    }
  }
}

module bearing(width, inner_radius, outer_radius, roller_radius=[2,4], min_wall_thickness=[2,2],print_angle=45, gap=0.15, bevel=[0.5,0.5], show_cross_section=false) {
  middle_radius = (outer_radius+inner_radius)/2;
  roller_radius0 = roller_radius[0];
  wall_thickness0 = middle_radius-inner_radius-roller_radius[1];//min_wall_thickness[0];
  wall_thickness1 = min_wall_thickness[1];
  roller_radius1 = roller_radius[1];//(outer_radius-inner_radius-2*gap-2*wall_thickness[0])/2
  
  if(wall_thickness0<min_wall_thickness[0]) {
    echo("Requred min_wall_thickness=",min_wall_thickness[0]," but calculated: ",wall_thickness0);
  }
  
  rotate_extrude_cond(angle=360,condition=!show_cross_section) {
    inner_ring_cross_section(
      r=inner_radius,
      r0=inner_radius+bevel[0],
      r1=inner_radius+wall_thickness0-bevel[0]-gap/2,
      r2=inner_radius+wall_thickness0-gap/2,
      r3=middle_radius-roller_radius0-gap/2,
      h1=bevel[1],
      h2=width/2-wall_thickness1/2-tan(print_angle)*(roller_radius1-roller_radius0)-bevel[1]+tan((90-print_angle)/2)*gap/2,
      h3=tan(print_angle)*(roller_radius1-roller_radius0),
      h4=wall_thickness1/2-tan((90-print_angle)/2)*gap/2
    );
  }
  //tan(a)=h3/(r1-r0)
  //cos(a)=x/gap
  step_angle_float=2*asin(roller_radius1/middle_radius);
  n=floor(360/step_angle_float);
  step_angle=360/n;
  echo(n);
  
  populate_rollers(step_angle=step_angle, radius=middle_radius, condition=!show_cross_section) {
      rotate_extrude_cond(angle=360,condition=!show_cross_section) {
          roller_cross_section(
            r1=roller_radius1-bevel[0]-gap/2,
            r2=roller_radius1-gap/2,
            r3=roller_radius0-gap/2,
            h1=bevel[1],
            h2=width/2-wall_thickness1/2-tan(print_angle)*(roller_radius1-roller_radius0)-bevel[1]+tan((90-print_angle)/2)*gap/2,
            h3=tan(print_angle)*(roller_radius1-roller_radius0),
            h4=wall_thickness1/2-tan((90-print_angle)/2)*gap/2
        );
    }
  }
  rotate_extrude_cond(angle=360,condition=!show_cross_section) {
    outer_ring_cross_section(
      r=outer_radius,
      r0=outer_radius-bevel[0],
      r1=outer_radius-wall_thickness0+bevel[0]+gap/2,
      r2=outer_radius-wall_thickness0+gap/2,
      r3=middle_radius+roller_radius0+gap/2,
      h1=bevel[1],
      h2=width/2-wall_thickness1/2-bevel[1]-tan(print_angle)*(roller_radius1-roller_radius0)+tan((90-print_angle)/2)*gap/2,
      h3=tan(print_angle)*(roller_radius1-roller_radius0),
      h4=wall_thickness1/2-tan((90-print_angle)/2)*gap/2
    );
  }
}

//bearing(width=10,inner_radius=10, outer_radius=22, roller_radius=[2.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.5,0.5],$fn=120);

bearing(width=10,inner_radius=2, outer_radius=14, roller_radius=[3.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.2,0.2],show_cross_section=false, $fn=120);
