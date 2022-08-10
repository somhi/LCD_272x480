module LCD_test ( 
  input   PixelClk,
  input   nRST,

  output  LCD_DE,
  output  LCD_HSYNC,
  output  LCD_VSYNC,
  
  output  [4:0] LCD_R,
  output  [5:0] LCD_G,
  output  [4:0] LCD_B
);
  
  reg [15:0]  PixelCount;
  reg [15:0]  LineCount;
  
  //pulse include in back pulse; t=pulse, sync act; t=bp, data act; t=bp+height, data end
	localparam  V_BackPorch = 16'd12; 
	localparam  V_Pulse   	= 16'd4; 
	localparam  HightPixel  = 16'd272;
	localparam  V_FrontPorch= 16'd8; 
	
	localparam  H_BackPorch = 16'd43; 
	localparam  H_Pulse 	  = 16'd4; 
	localparam  WidthPixel  = 16'd480;
	localparam  H_FrontPorch= 16'd8;

  localparam  PixelForHS  = WidthPixel + H_BackPorch + H_FrontPorch;
  localparam  LineForVS   = HightPixel + V_BackPorch + V_FrontPorch;
  

  always @( posedge PixelClk or negedge nRST )begin
    if( !nRST ) begin
        LineCount   <=  16'b0;
        PixelCount  <=  16'b0;
    end
    else if(  PixelCount == PixelForHS  ) begin
        PixelCount  <=  16'b0;
        LineCount   <=  LineCount + 1'b1;
    end
    else if(  LineCount == LineForVS  ) begin
        LineCount   <=  16'b0;
        PixelCount  <=  16'b0;
    end
    else
        PixelCount  <=  PixelCount +  1'b1;
  end

  //Note the negative polarity of HSYNC and VSYNC here
  assign LCD_HSYNC = (( PixelCount >= H_Pulse )&&( PixelCount <= ( PixelForHS - H_FrontPorch ))) ? 1'b0 : 1'b1;
  assign LCD_VSYNC = ((( LineCount >= V_Pulse )&&( LineCount  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;
  //assign  LCD_VSYNC = ((( LineCount  >= 0 )&&( LineCount  <= (V_Pluse-1) )) ) ? 1'b1 : 1'b0;		//If you don't subtract one here, the bottom of the picture will trail down?
  //assign  FIFO_RST  = (( PixelCount ==0)) ? 1'b1 : 1'b0;  //Time left for host H_BackPorch to enter interrupt, send data

  assign LCD_DE = ( ( PixelCount >= H_BackPorch )&&
                    ( PixelCount <= PixelForHS - H_FrontPorch )&&
                    ( LineCount  >= V_BackPorch  )&&
                    ( LineCount  <= LineForVS - V_FrontPorch-1)) ? 1'b1 : 1'b0;
					          //Not minus one here, it will shake


  /* SQUARE */
  // reg square;
  // always @* begin
  //   square = ( PixelCount > 180 && PixelCount < 380) && ( LineCount >48 && LineCount < 248);
  // end
  
  // reg [4:0] paint_r;
  // reg [5:0] paint_g;
  // reg [4:0] paint_b;
  
  // always @* begin
  //   paint_r = (square) ? 5'b10000 : 5'b00000;
  //   paint_g = (square) ? 6'b100000 : 6'b000000;
  //   paint_b = (square) ? 5'b10000 : 5'b10000;
  // end
                      
  // assign LCD_R = paint_r;
  // assign LCD_G = paint_g;
  // assign LCD_B = paint_b;

                    
  /* COLOR STRIPS 1*/
  //  assign  LCD_R   =   (PixelCount<51) ? 5'b00000 : 
  //                      (PixelCount<111 ? 5'b00000 :    
  //                      (PixelCount<171 ? 5'b10000 :    
  //                      (PixelCount<231 ? 5'b10000 :    
  //                      (PixelCount<291 ? 5'b00000 :    
  //                      (PixelCount<351 ? 5'b00000 : 
  //                      (PixelCount<411 ? 5'b00000 :  
  //                      (PixelCount<471 ? 5'b10000 : 5'b10000 )))))));
                       

  //  assign  LCD_G   =   (PixelCount<111)? 6'b000000 : 
  //                      (PixelCount<171 ? 6'b000000 :    
  //                      (PixelCount<231 ? 6'b100000 :    
  //                      (PixelCount<291 ? 6'b100000 :    
  //                      (PixelCount<351 ? 6'b100000 :    
  //                      (PixelCount<411 ? 6'b000000 :  
  //                      (PixelCount<471 ? 6'b000000 : 6'b100000 ))))));

  //  assign  LCD_B   =   (PixelCount<171)? 5'b00000 : 
  //                      (PixelCount<171 ? 5'b00000 :    
  //                      (PixelCount<231 ? 5'b00000 :    
  //                      (PixelCount<291 ? 5'b00000 :    
  //                      (PixelCount<351 ? 5'b10000 :
  //                      (PixelCount<411 ? 5'b10000 : 
  //                      (PixelCount<471 ? 5'b10000 :  5'b10000 ))))));


  /* COLOR STRIPS 2*/
  // assign  LCD_R   =   (PixelCount<  ( H_BackPorch+480 )  ? 5'b11110  :  5'b00000 );  //red
  // assign  LCD_G   =   (PixelCount<  ( H_BackPorch+320 )  ? 6'b111110 :  6'b000000 ); //yellow 
  // assign  LCD_B   =   (PixelCount<  ( H_BackPorch+160 )  ? 5'b11110  :  5'b00000 );  //white


  /* COLOR STRIPS 3*/
    localparam          Width_bar =   40;
    localparam          BarCount  =    0;

    assign  LCD_R   =   (PixelCount<H_BackPorch+(Width_bar*(BarCount+1)) ? 5'b00011 :                      //40
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+2)) ? 5'b00111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+3)) ? 5'b01111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+4)) ? 5'b11111 :  5'b00000 ))));      //150

    assign  LCD_G   =   (PixelCount<H_BackPorch+(Width_bar*(BarCount+4)))? 6'b000000 :                     //150
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+5)) ? 6'b000111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+6)) ? 6'b001111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+7)) ? 6'b011111 :  
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+8)) ? 6'b111111 : 6'b000000 ))));    //330

    assign  LCD_B   =   (PixelCount<H_BackPorch+(Width_bar*(BarCount+8)))? 5'b00000 :                     //330
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+9)) ? 5'b00011 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+10))? 5'b00111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+11))? 5'b01111 :    
                        (PixelCount<H_BackPorch+(Width_bar*(BarCount+12))? 5'b11111 :  5'b00000 ))));     //480

endmodule 
