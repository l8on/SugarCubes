/**
 *     DOUBLE BLACK DIAMOND        DOUBLE BLACK DIAMOND
 *
 *         //\\   //\\                 //\\   //\\  
 *        ///\\\ ///\\\               ///\\\ ///\\\
 *        \\\/// \\\///               \\\/// \\\///
 *         \\//   \\//                 \\//   \\//
 *
 *        EXPERTS ONLY!!              EXPERTS ONLY!!
 *
 * This class implements the mapping functions needed to lay out the physical
 * cubes and the output ports on the panda board. It should only be modified
 * when physical changes or tuning is being done to the structure.
 */
class SCMapping implements GLucose.Mapping {
  public Cube[] buildCubeArray() {
    // TODO(mcslee): find a cleaner way of representing this data, probably
    // serialized in some more neutral form. also figure out what's going on
    // with the indexing starting at 1 and some indices missing.
    Cube[] cubes = new Cube[79];
    cubes[1]  = new Cube(17.25, 0, 0, 0, 0, 80, true, 2, 3);
    cubes[2]  = new Cube(50.625, -1.5, 0, 0, 0, 55, false, 4, 0);
    cubes[3]  = new Cube(70.75, 12.375, 0, 0, 0, 55, false, 4, 0);
    cubes[4]  = new Cube(49.75, 24.375, 0, 0, 0, 48, false, 0, 0);//dnw
    cubes[5]  = new Cube(14.25, 32, 0, 0, 0, 80, false, 2, 1);
    cubes[6]  = new Cube(50.375, 44.375, 0, 0, 0, 0, false, 0, 0);//dnw
    cubes[7]  = new Cube(67.5, 64.25, 0, 27, 0, 0, false, 0, 0);//dnw
    cubes[8]  = new Cube(44, 136, 0, 0, 0, 0, false, 1, 2);
    cubes[9]  = new Cube(39, 162, 0, 0, 0, 0, false, 1, 0);
    cubes[10] = new Cube(58, 182, -4, 12, 0, 0, false, 3, 3);
    cubes[11] = new Cube(28, 182, -4, 12, 0, 0, false, 0, 0);
    cubes[12] = new Cube(0, 182, -4, 12, 0, 0, false, 0, 2);
    cubes[13] = new Cube(18.75, 162, 0, 0, 0, 0, false, 0, 0);
    cubes[14] = new Cube(13.5, 136, 0, 0, 0, 0, false, 1, 1);
    cubes[15] = new Cube(6.5, -8.25, 20, 0, 0, 25, false, 5, 3);
    cubes[16] = new Cube(42, 15, 20, 0, 0, 4, true, 2, 2);
    cubes[17] = new Cube(67, 24, 20, 0, 0, 25);
    cubes[18] = new Cube(56, 41, 20, 0, 0, 30, false, 3, 1);
    cubes[19] = new Cube(24, 2, 20, 0, 0, 25, true, 0, 3);
    cubes[20] = new Cube(26, 26, 20, 0, 0, 70, true, 2, 3);
    cubes[21] = new Cube(3.5, 10.5, 20, 0, 0, 35, true, 1, 0);
    cubes[22] =  new Cube(63, 133, 20, 0, 0, 80, false, 0, 2);
    cubes[23] = new Cube(56, 159, 20, 0, 0, 65);
    cubes[24] = new Cube(68, 194, 20, 0, -45, 0);
    cubes[25] = new Cube(34, 194, 20, 20, 0, 35 );
    cubes[26] = new Cube(10, 194, 20, 0, -45, 0 ); // wired a bit funky
    cubes[27] = new Cube(28, 162, 20, 0, 0, 65);
    cubes[28] = new Cube(15.5, 134, 20, 0, 0, 20);
    cubes[29] = new Cube(13, 29, 40, 0, 0, 0, true, 0, 0);
    cubes[30] = new Cube(55, 15, 40, 0, 0, 50, false, 0, 2);
    cubes[31] = new Cube(78, 9, 40, 0, 0, 60, true, 5, 2);
    cubes[32] = new Cube(80, 39, 40, 0, 0, 80, false, 0, 3);
    cubes[33] = new Cube(34, 134, 40, 0, 0, 50, false, 0, 3);
    cubes[34] = new Cube(42, 177, 40, 0, 0, 0);
    cubes[35] = new Cube(41, 202, 40, 20, 0, 80);
    cubes[36] = new Cube(21, 178, 40, 0, 0, 35);
    cubes[37] = new Cube(18, 32, 60, 0, 0, 65, true, 0, 1);
    cubes[38] = new Cube(44, 20, 60, 0, 0, 20); //front power cube
    cubes[39] = new Cube(39, 149, 60, 0, 0, 15);
    cubes[40] = new Cube(60, 186, 60, 0, 0, 45);
    cubes[41] = new Cube(48, 213, 56, 20, 0, 25);
    cubes[42] = new Cube(22, 222, 60, 10, 10, 15, false, 0, 3);
    cubes[43] = new Cube(28, 198, 60, 20, 0, 20, true, 5, 0);
    cubes[44] = new Cube(12, 178, 60, 0, 0, 50, false, 4, 1);
    cubes[45] = new Cube(18, 156, 60, 0, 0, 40);
    cubes[46] = new Cube(30, 135, 60, 0, 0, 45);
    cubes[47] = new Cube(10, 42, 80, 0, 0, 17, true, 0, 2);
    cubes[48] = new Cube(34, 23, 80, 0, 0, 45, false, 0, 1);
    cubes[49] = new Cube(77, 28, 80, 0, 0, 45);
    cubes[50] = new Cube(53, 22, 80, 0, 0, 45);
    cubes[51] = new Cube(48, 175, 80, 0, 0, 45); 
    cubes[52] = new Cube(66, 172, 80, 0, 0, 355, true, 5, 1);// _,195,_ originally
    cubes[53] = new Cube(33, 202, 80, 25, 0, 85, false, 1, 3);
    cubes[54] = new Cube(32, 176, 100, 0, 0, 20, false, 0, 2);
    cubes[55] = new Cube(5.75, 69.5, 0, 0, 0, 80);
    cubes[56] = new Cube(1, 53, 0, 40, 70, 70);
    cubes[57] = new Cube(-15, 24, 0, 15, 0, 0);
    //cubes[58] what the heck happened here? never noticed before 4/8/2013
    //cubes[59] what the heck happened here? never noticed before 4/8/2013
    cubes[60] = new Cube(40, 164, 120, 0, 0, 12.5, false, 4, 3);
    cubes[61] = new Cube(32, 148, 100, 0, 0, 3, false, 4, 2);
    cubes[62] = new Cube(30, 132, 90, 10, 350, 5);
    cubes[63] = new Cube(22, 112, 100, 0, 20, 0, false, 4, 0);
    cubes[64] = new Cube(35, 70, 95, 15, 345, 20);
    cubes[65] = new Cube(38, 112, 98, 25, 0, 0, false, 4, 3);
    cubes[66] = new Cube(70, 164, 100, 0, 0, 22);
    cubes[68] = new Cube(29, 94, 105, 15, 20, 10, false, 4, 0);
    cubes[69] = new Cube(30, 77, 100, 15, 345, 20, false, 2, 1);
    cubes[70] = new Cube(38, 96, 95, 30, 0, 355);
    //cubes[71]= new Cube(38,96,95,30,0,355);
    cubes[72] = new Cube(44, 20, 100, 0, 0, 345);
    cubes[73] = new Cube(28, 24, 100, 0, 0, 13, true, 5, 1);
    cubes[74] = new Cube(8, 38, 100, 10, 0, 0, true, 5, 1);
    cubes[75] = new Cube(20, 58, 100, 0, 0, 355, false, 2, 3);
    cubes[76] = new Cube(22, 32, 120, 15, 327, 345, false, 4, 0); 
    cubes[77] = new Cube(50, 132, 80, 0, 0, 0, false, 0, 2); 
    cubes[78] = new Cube(20, 140, 80, 0, 0, 0, false, 0, 3);
    return cubes;
  }
}

