module LCD_test ( 
  input   PixelClk,
  input   nRST,

  output  LCD_DE,
  output  LCD_HSYNC,
  output  LCD_VSYNC,
  
  output  [4:0] LCD_B,
  output  [5:0] LCD_G,
  output  [4:0] LCD_R
);
  
  reg [15:0]  PixelCount;
  reg [15:0]  LineCount;
  
  //pulse include in back pulse; t=pulse, sync act; t=bp, data act; t=bp+height, data end
	localparam  V_BackPorch = 16'd12; 
	localparam  V_Pulse 	= 16'd11; 
	localparam  HightPixel  = 16'd272;
	localparam  V_FrontPorch= 16'd8; 
	
	localparam  H_BackPorch = 16'd50; 
	localparam  H_Pulse 	= 16'd10; 
	localparam  WidthPixel  = 16'd480;
	localparam  H_FrontPorch= 16'd8;

//	localparam  V_BackPorch = 16'd6; 
//	localparam  V_Pulse 	= 16'd8; 
//	localparam  HightPixel  = 16'd272;
//	localparam  V_FrontPorch= 16'd1; 
//	
//	localparam  H_BackPorch = 16'd40; 
//	localparam  H_Pulse 	= 16'd32; 
//	localparam  WidthPixel  = 16'd480;
//	localparam  H_FrontPorch= 16'd8;
  
  localparam  PixelForHS = WidthPixel + H_BackPorch + H_FrontPorch;
  localparam  LineForVS  = HightPixel + V_BackPorch + V_FrontPorch;
  
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


  //Tenga en cuenta la polaridad negativa de HSYNC y VSYNC aquí
  assign LCD_HSYNC = (( PixelCount >= H_Pulse )&&( PixelCount <= ( PixelForHS - H_FrontPorch ))) ? 1'b0 : 1'b1;
  
  assign LCD_VSYNC = ((( LineCount >= V_Pulse )&&( LineCount <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;
  
  assign LCD_DE = ( ( PixelCount >= H_BackPorch )&&
                    ( PixelCount <= PixelForHS - H_FrontPorch )&&
                    ( LineCount >= V_BackPorch)&&
                    ( LineCount <= LineForVS - V_FrontPorch-1)) ? 1'b1 : 1'b0;


  /* SQUARE */
    
  reg square;
  always @* begin
    square = ( PixelCount > 180 && PixelCount < 380) && ( LineCount >48 && LineCount < 248);
  end
  
  reg [4:0] paint_r;
  reg [5:0] paint_g;
  reg [4:0] paint_b;
  
  always @* begin
    paint_r = (square) ? 5'b10000 : 5'b00000;
    paint_g = (square) ? 6'b100000 : 6'b000000;
    paint_b = (square) ? 5'b10000 : 5'b10000;
  end
                      
  // assign LCD_R = paint_r;
  // assign LCD_G = paint_g;
  // assign LCD_B = paint_b;

                    
/* Barras de color */
   assign  LCD_R   =   (PixelCount<51)? 5'b00000 : 
                       (PixelCount<111 ? 5'b00000 :    
                       (PixelCount<171 ? 5'b10000 :    
                       (PixelCount<231 ? 5'b10000 :    
                       (PixelCount<291 ? 5'b00000 :    
                       (PixelCount<351 ? 5'b00000 : 
                       (PixelCount<411 ? 5'b00000 :  
                       (PixelCount<471 ? 5'b10000 : 5'b10000 )))))));
                       

   assign  LCD_G   =   (PixelCount<111)? 6'b000000 : 
                       (PixelCount<171 ? 6'b000000 :    
                       (PixelCount<231 ? 6'b100000 :    
                       (PixelCount<291 ? 6'b100000 :    
                       (PixelCount<351 ? 6'b100000 :    
                       (PixelCount<411 ? 6'b000000 :  
                       (PixelCount<471 ? 6'b000000 : 6'b100000 ))))));

   assign  LCD_B   =   (PixelCount<171)? 5'b00000 : 
                       (PixelCount<171 ? 5'b00000 :    
                       (PixelCount<231 ? 5'b00000 :    
                       (PixelCount<291 ? 5'b00000 :    
                       (PixelCount<351 ? 5'b10000 :
                       (PixelCount<411 ? 5'b10000 : 
                       (PixelCount<471 ? 5'b10000 :  5'b10000 ))))));

  
endmodule 