


module byte_aligner_wrapper #(
    parameter LANE_NUM = 4,
    parameter BYTE_NUM = 1
    )(
    input wire                            I_clk,
    input wire                            I_rst,

    input wire                            I_hs_rx_valid,
    input wire[8*LANE_NUM*BYTE_NUM-1 : 0] I_hs_rx_data,

    output wire[LANE_NUM-1 : 0]           O_byte_aligne_valid,
    output wire[8*BYTE_NUM-1 : 0]         O_byte_aligne_data[LANE_NUM-1 : 0],

    output wire[LANE_NUM-1 : 0]           O_lane_error
);

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
pLgASUQGuFnZ4mnS/ozlnu32Vb18JSReL1+qzTMUffGaf4wpPzFMSO8I25anab6D
rD6Kdt97wZZ7ktEzpDQatuKsUUk6oE5hhUXIWVnGdagp2osyPoTz+TDp2jJhqH10
0tOSlwVffxC4hABU7Fn5r9EVzw+ludFtoTnTE7JXfQU=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
VZezwqzFKEJzE5mEup4Hgk8bmPK3BKQr+Ajo+R2OV2NgvjbHhC6y5PYBdrfVXyi9
eJKt2dCOjr2UnaaxpBYmhFvpzxqJ88rg9BYGkFACJC7PsRlSI3kbWvfAmZsgBxgP
Ul9tvA++2FElRt6w1l0zajSC/4kMC9VYZGAyHIA0ts9akO4RQqrf0bv5ZXwo2d5m
VrL2AFnGDIGPwquO5slOZzU6txXgVjUUbAkfF0SP8FGFJBQAkDqUJxEB4Cp0urvF
tW2NuJ3ntWKaFNV7JGKHTHhS0I25jYRuXUw8po5nqPYBIOFE6fINGOmcKZ1QfiiM
VNuc/7PPqIrMcz5jPikytg==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
HZgpKUr7k8aHWpe0k8XRP6TXb+SnmoDeiESHjVsziI8T6GDt/KiSaliD9W5ocPMw
arMZYjaAWFdOzzznVJjCwy6BSlxxhouVEY226RmdnMtUTdWzfsllh1a5SoPlP8TM
O5RpU1y3BoPMRiV9jB9WlWF6DGQT1o6YZ8JWeFPbGBI=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
TE3J/JAvUr3Hpq4Q8FWT2w8u2QO4U1EermnMkOZswmrOxOBKjW/pa3CtIDVGeALC
02smVC7JpSf160ivqrvhT3EhHEu12UnKhE5pgmE42mRyfzTfAQz8OvGEMMUTg3F9
UPSMW/yegIJ3YufIRB1BOVkOl36IEvuYey7BvYTGLcpJbHfu+QKHesClE0sBej7n
oufr69///FXZ7S8skXNwJQyge1MKt8VfcnMYIhu5YUvUMNECKeHVaWrR64KWQtdm
c4m2tB3ibdglIL3TH5qrn7sWuqyGJmZ38Xtr+rGAc/AjNdG5UiYUtvrK6Ne1Tfjw
vN8qC+K7awSmK9wakcj0Gg==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
mrk+a+F8rDU0tMO6LuR9phWAwupz8aDA5BpR6E211YB1yRw2LmP39ok8bFhXMS8v
lH8sV2/83pfI2YftOlOdZmnpE/iEMu+s5+gT24ZirPi3narU1F3qRXIvY9c48rw2
w6jkEEbbarRlRKREDzakpf9m0QgbUicf1BMnOL3e+BU=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 2512)
`pragma protect data_block
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
/Ol2W+kyXtNYrX/q2y5LfQ==
`pragma protect end_protected

endmodule