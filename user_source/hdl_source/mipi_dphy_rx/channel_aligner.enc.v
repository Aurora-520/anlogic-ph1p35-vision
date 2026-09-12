

module channel_aligner #(
    parameter DATA_WIDTH = 8
    )(
    input wire                 I_clk,
    input wire                 I_rst_n,
             
    input wire                 I_all_ch_valid,
    input wire                 I_ch_valid,
    input wire[DATA_WIDTH-1:0] I_ch_data,
 
    output reg                 O_aligner_valid,
    output reg[DATA_WIDTH-1:0] O_aligner_data
);

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
kPOHXXEzRTVUXqrTZ08DTxZxbzvA0ffP+qJwzORFIMrNhxs4WMUVCU1ydkgMQz3c
g8UgBg9BNlhNDy2HAWUnNKcmSIkn1zvSgzCMOVRo6Wl1+gWkoZX7ddXr3dYmElmG
Pe8u8XcpDORGI79+i1pQAFKuMNz+Ad9TocMZ+xV0heQ=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
oiONs0JTZ17ZLWhpehYM857XFG/E0jdQv1sJidIeu2zYP01GUE77FhM6V/KkycR+
282+BjKLr045R8E4AtqbI998/qKppMjyxjjdvLuCDvteTIMpSXJeghUotJIxa1pZ
MrKQBdO+iyD/53gHawxfmCBNDeS++7Q5Ib9ZqWSJ+174HMi4a/nQRgI5nN9Kg9+J
c5wEjyyqib5hDOBINMzSyxmui/QNcWvf2O7nFSbv1zC9T1uiaPrsDvjb0E7tmQRD
m2/AsSPtIWKRxMN+L6ZuomhY0E+nG1VY0muk2wL0b4pxbW+sMvy9E42lMAemKHhh
XEFEKu8JDGEQHPISmVtfoA==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
cStsFMUHWzLD4zcxgo7/jkNj2/jA+Ob1qyXjwEYIYo6yGLSBX5egNCml4HybxdOZ
mGf8SGPxpFzWqwJ3yIPZe7v/D/YsZQLCMHJWtT77OrZn8lOOz8ioMP1V1Yc5kRMN
T/VUV4ZLgXQM1u8j9saFK0Me1j+SMn5OOiPJsdtqsZg=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
DqKi4hc/AxiqTUVYJbOPw5e8zciBKNw9C4Gf17j0TY839t7IJr18hLKZHV7xLYxP
nOMlnOsxG+sVrx0UQeoZF4CceBqIakAx8qfTciyqn1HJyFiL4gN/2eUyBSZTud6h
x4DpFkTjeh5pOBMPi31k+hyzJ0Af3gEidgH7Cu3/qbDYC5w2gg5TLeFBVKltsSzL
lfOQDDTrakADuoK8NUQRxK3tum7PRdXsdn3bM6F2MjqWZHXuisue8Mf+VLtlraFj
Yam0VAbKDZTlZeDCx9nlP7mEL8uAJJcKldayXMYH19Ov8+CaDQ25wYxFBrxYscOq
5TVvojr5v/CGcxpKL2v6Jg==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
GTpvfiaeyNfvkBBR1JWdhE6590+/Zef75gv5S8trM0BtOgPxit5GYbiuWs6aWn+h
w4OhWsft1w4+nWTHwYuSSZO1X0j2DeXifn7rIy65ljzCdEt4R1ccn6j/Hk7D5Jea
b/CFjbQ47A8QEmkV6+WDPZlziMSQC9GjnEDRJpH/GK0=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 3248)
`pragma protect data_block
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
`pragma protect end_protected

endmodule