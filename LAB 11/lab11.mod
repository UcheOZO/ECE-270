MODEL
MODEL_VERSION "1.0";
DESIGN "lab11";
DATE "Thu Apr 04 07:43:00 2019";
VENDOR "Lattice Semiconductor Corporation";
PROGRAM "STAMP Model Generator";

/* port name and type */
INPUT DIP_0;
INPUT DIP_1;
INPUT DIP_2;
INPUT DIP_3;
INPUT DIP_4;
INPUT DIP_5;
INPUT DIP_6;
INPUT DIP_7;
INPUT i_S1_NC;
INPUT i_S1_NO;
INPUT i_S2_NC;
INPUT i_S2_NO;
OUTPUT o_BOTRED_0;
OUTPUT o_BOTRED_1;
OUTPUT o_BOTRED_2;
OUTPUT o_BOTRED_3;
OUTPUT o_BOTRED_4;
OUTPUT o_BOTRED_5;
OUTPUT o_BOTRED_6;
OUTPUT o_BOTRED_7;
OUTPUT o_DIS1_0;
OUTPUT o_DIS1_1;
OUTPUT o_DIS1_2;
OUTPUT o_DIS1_3;
OUTPUT o_DIS1_4;
OUTPUT o_DIS1_5;
OUTPUT o_DIS1_6;
OUTPUT o_DIS2_0;
OUTPUT o_DIS2_1;
OUTPUT o_DIS2_2;
OUTPUT o_DIS2_3;
OUTPUT o_DIS2_4;
OUTPUT o_DIS2_5;
OUTPUT o_DIS2_6;
OUTPUT o_DIS3_0;
OUTPUT o_DIS3_1;
OUTPUT o_DIS3_2;
OUTPUT o_DIS3_3;
OUTPUT o_DIS3_4;
OUTPUT o_DIS3_5;
OUTPUT o_DIS3_6;
OUTPUT o_DIS4_0;
OUTPUT o_DIS4_1;
OUTPUT o_DIS4_2;
OUTPUT o_DIS4_3;
OUTPUT o_DIS4_4;
OUTPUT o_DIS4_5;
OUTPUT o_DIS4_6;
OUTPUT o_JUMBO_0;
OUTPUT o_JUMBO_1;
OUTPUT o_JUMBO_2;
OUTPUT o_LED_YELLOW_0;
OUTPUT o_LED_YELLOW_1;
OUTPUT o_MIDRED_0;
OUTPUT o_MIDRED_1;
OUTPUT o_MIDRED_2;
OUTPUT o_MIDRED_3;
OUTPUT o_MIDRED_4;
OUTPUT o_MIDRED_5;
OUTPUT o_MIDRED_6;
OUTPUT o_MIDRED_7;
OUTPUT o_TOPRED_0;
OUTPUT o_TOPRED_1;
OUTPUT o_TOPRED_2;
OUTPUT o_TOPRED_3;
OUTPUT o_TOPRED_4;
OUTPUT o_TOPRED_5;
OUTPUT o_TOPRED_6;
OUTPUT o_TOPRED_7;

/* timing arc definitions */
DIP_7_o_BOTRED_7_delay: DELAY DIP_7 o_BOTRED_7;
DIP_4_o_BOTRED_4_delay: DELAY DIP_4 o_BOTRED_4;
DIP_5_o_BOTRED_5_delay: DELAY DIP_5 o_BOTRED_5;
DIP_5_o_TOPRED_0_delay: DELAY DIP_5 o_TOPRED_0;
DIP_5_o_TOPRED_1_delay: DELAY DIP_5 o_TOPRED_1;
DIP_5_o_TOPRED_2_delay: DELAY DIP_5 o_TOPRED_2;
DIP_5_o_TOPRED_3_delay: DELAY DIP_5 o_TOPRED_3;
DIP_5_o_TOPRED_4_delay: DELAY DIP_5 o_TOPRED_4;
DIP_5_o_TOPRED_5_delay: DELAY DIP_5 o_TOPRED_5;
DIP_5_o_TOPRED_6_delay: DELAY DIP_5 o_TOPRED_6;
DIP_5_o_TOPRED_7_delay: DELAY DIP_5 o_TOPRED_7;
DIP_6_o_BOTRED_6_delay: DELAY DIP_6 o_BOTRED_6;
DIP_0_o_BOTRED_0_delay: DELAY DIP_0 o_BOTRED_0;
DIP_1_o_BOTRED_1_delay: DELAY DIP_1 o_BOTRED_1;
DIP_2_o_BOTRED_2_delay: DELAY DIP_2 o_BOTRED_2;
DIP_3_o_BOTRED_3_delay: DELAY DIP_3 o_BOTRED_3;
i_S1_NO_o_LED_YELLOW_0_delay: DELAY i_S1_NO o_LED_YELLOW_0;
i_S2_NO_o_LED_YELLOW_1_delay: DELAY i_S2_NO o_LED_YELLOW_1;

/* timing check arc definitions */

ENDMODEL
