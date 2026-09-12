/*****************************************************************
Company : Nanjing Weiku Robot Technology Co., Ltd.
Brand   : VLKUS
Technical forum:www.uisrc.com
@Author      :   XiaoQingquan 
@Time        :   2024/09/18 
@Description :   
*****************************************************************/

module data128_96 (

    input  wire [127:0] I_tdata,
    output wire [ 95:0] O_tdata
);

  assign O_tdata = {I_tdata[23:0], I_tdata[55:32], I_tdata[87:64], I_tdata[119:96]};
  //assign O_tdata = {I_tdata, I_tdata, I_tdata[55:32], I_tdata[23:0]};

endmodule
