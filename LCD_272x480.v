module LCD_272x480 (
  input			    KEY0,
  input         MAX10_CLK1_50,

	output		  	LCD_CLK,
	output		  	LCD_HSYNC,
	output		  	LCD_VSYNC,
	output	  		LCD_DEN,
	output	[3:0]	LCD_R,
	output	[3:0]	LCD_G,
	output	[3:0]	LCD_B
);

  wire  CLK_SYS;
  wire  CLK_PIX;
  wire [4:0] lcd_r;
  wire [5:0] lcd_g;
  wire [4:0] lcd_b;
  
  LCD_pll	LCD_pll_inst (
    .areset ( ~KEY0 ),
    .inclk0 ( MAX10_CLK1_50 ),
    .c0     ( CLK_PIX )
    //.c1 ( CLK_SYS )
    //.locked ( locked_sig )
	);
	
  assign  LCD_CLK = CLK_PIX;

  LCD_test  D1 (
		.PixelClk	(	CLK_PIX		),
    .nRST	   	(	KEY0	    ),

		.LCD_DE		(	LCD_DEN	 	),
		.LCD_HSYNC(	LCD_HSYNC ),
    .LCD_VSYNC(	LCD_VSYNC ),

		.LCD_R		(	lcd_r		  ),
    .LCD_G		(	lcd_g		  ),
    .LCD_B		(	lcd_b		  )
  );
  
  assign  LCD_R = lcd_r[4:1];
  assign  LCD_G = lcd_g[5:2];
  assign  LCD_B = lcd_b[4:1];
  
  
endmodule
