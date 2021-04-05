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

module bearing_cross_section(width, inner_radius, outer_radius, roller_radius=[2,4], min_wall_thickness=[2,2],print_angle=45, gap=0.15, bevel=[0.5,0.5]) {
  middle_radius = (outer_radius+inner_radius)/2;
  roller_radius0 = roller_radius[0];
  wall_thickness0 = middle_radius-inner_radius-roller_radius[1];//min_wall_thickness[0];
  wall_thickness1 = min_wall_thickness[1];
  roller_radius1 = roller_radius[1];//(outer_radius-inner_radius-2*gap-2*wall_thickness[0])/2
  
  if(wall_thickness0<min_wall_thickness[0]) {
    echo("Requred min_wall_thickness=",min_wall_thickness[0]," but calculated: ",wall_thickness0);
  }
  
  inner_ring_cross_section(r=inner_radius,r0=inner_radius+bevel[0],r1=middle_radius-roller_radius0-bevel[0]-gap/2,r2=middle_radius-roller_radius0-gap/2,r3=inner_radius+wall_thickness0-gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]-cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)+cos(print_angle)*gap/2);
  //tan(a)=h3/(r1-r0)
  //cos(a)=x/gap
  
  translate(v=[middle_radius,0,0]) {
    rotate(a=000,v=[0,1,0]) roller_cross_section(r1=roller_radius0-bevel[0]-gap/2,r2=roller_radius0-gap/2,r3=roller_radius1-gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]+cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)-cos(print_angle)*gap/2);
    rotate(a=180,v=[0,1,0]) roller_cross_section(r1=roller_radius0-bevel[0]-gap/2,r2=roller_radius0-gap/2,r3=roller_radius1-gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]+cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)-cos(print_angle)*gap/2);
  }  
  
  outer_ring_cross_section(r=outer_radius,r0=outer_radius-bevel[0],r1=middle_radius+roller_radius0+bevel[0]+gap/2,r2=middle_radius+roller_radius0+gap/2,r3=outer_radius-wall_thickness0+gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]-cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)+cos(print_angle)*gap/2);
}

//bearing_cross_section(width=10,inner_radius=10, outer_radius=22, roller_radius=[2.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.5,0.5]);
//bearing_cross_section(width=10,inner_radius=2, outer_radius=14, roller_radius=[2.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.5,0.5],$fn=120);

module roller_imp(r1,r2,r3,h1,h2,h3,h4,$fn=$fn) {
  /*union() {
    half_roller_imp(r1=r1,r2=r2,r3=r3,h1=h1,h2=h2,h3=h3,h4=h4,$fn=$fn);
    translate([0,0,2*(h1+h2+h3+h4)]) {
      rotate(a=180,v=[1,0,0]) {
        half_roller_imp(r1=r1,r2=r2,r3=r3,h1=h1,h2=h2,h3=h3,h4=h4,$fn=$fn);
      }
    }
  }//*/
  rotate_extrude(angle=360) {
    roller_cross_section(r1,r2,r3,h1,h2,h3,h4);
  }
}

module inner_ring_imp(r1,r2,r3,h1,h2,h3,h4,$fn=$fn) {
  roller_imp(r1,r2,r3,h1,h2,h3,h4,$fn=$fn);
}

module outer_ring_imp(r1,r2,r3,h1,h2,h3,h4,r,$fn=$fn) {
  outer_ring_cross_section(r1,r2,r3,h1,h2,h3,h4,r);
  /*
  difference() {
    cylinder(h=(2*(h1+h2+h3+h4)),r=r);
    translate([0,0,-boolean_op_margin]) {
      roller_imp(r1,r2,r3,h1+boolean_op_margin,h2,h3,h4,$fn=$fn);
    }
  }
  //*/
}


module bearing(width, inner_radius, outer_radius, roller_radius=[2,4], min_wall_thickness=[2,2],print_angle=45, gap=0.15, bevel=[0.5,0.5]) {
  middle_radius = (outer_radius+inner_radius)/2;
  roller_radius0 = roller_radius[0];
  wall_thickness0 = middle_radius-inner_radius-roller_radius[1];//min_wall_thickness[0];
  wall_thickness1 = min_wall_thickness[1];
  roller_radius1 = roller_radius[1];//(outer_radius-inner_radius-2*gap-2*wall_thickness[0])/2
  
  if(wall_thickness0<min_wall_thickness[0]) {
    echo("Requred min_wall_thickness=",min_wall_thickness[0]," but calculated: ",wall_thickness0);
  }
  
  rotate_extrude(angle=360) {
    inner_ring_cross_section(r=inner_radius,r0=inner_radius+bevel[0],r1=middle_radius-roller_radius0-bevel[0]-gap/2,r2=middle_radius-roller_radius0-gap/2,r3=inner_radius+wall_thickness0-gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]-cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)+cos(print_angle)*gap/2);
  }
  //tan(a)=h3/(r1-r0)
  //cos(a)=x/gap
  step_angle_float=2*asin(roller_radius1/middle_radius);
  n=floor(360/step_angle_float);
  step_angle=360/n;
  echo(n);
  
  for(i=[0:step_angle:360]) {
    rotate(a=i,v=[0,0,1]) {
      translate(v=[middle_radius,0,0]) {
        rotate_extrude(angle=360) {
          roller_cross_section(r1=roller_radius0-bevel[0]-gap/2,r2=roller_radius0-gap/2,r3=roller_radius1-gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]+cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)-cos(print_angle)*gap/2);
        }
      }
    }
  }  
  rotate_extrude(angle=360) {
    outer_ring_cross_section(r=outer_radius,r0=outer_radius-bevel[0],r1=middle_radius+roller_radius0+bevel[0]+gap/2,r2=middle_radius+roller_radius0+gap/2,r3=outer_radius-wall_thickness0+gap/2,h1=bevel[1],h2=wall_thickness1-bevel[1]-cos(print_angle)*gap/2,h3=tan(print_angle)*(roller_radius1-roller_radius0),h4=width/2-wall_thickness1-tan(print_angle)*(roller_radius1-roller_radius0)+cos(print_angle)*gap/2);
  }
}

//bearing(width=10,inner_radius=10, outer_radius=22, roller_radius=[2.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.5,0.5],$fn=120);

bearing(width=10,inner_radius=2, outer_radius=14, roller_radius=[2.0,4.0], min_wall_thickness=[2,2], print_angle=45, gap=0.15, bevel=[0.2,0.2],$fn=120);
