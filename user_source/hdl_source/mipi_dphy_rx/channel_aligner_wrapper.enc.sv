

module channel_aligner_wrapper #(
    parameter CH_NUM     = 4,
    parameter DATA_WIDTH = 8
    )(
    input wire                  I_clk,
    input wire                  I_rst_n,
        
    input wire[CH_NUM-1:0]      I_ch_valid,
    input wire[DATA_WIDTH-1:0]  I_ch_data[CH_NUM-1:0],

    output wire[CH_NUM-1:0]     O_ch_aligner_valid,
    output wire[DATA_WIDTH-1:0] O_ch_aligner_data[CH_NUM-1:0]
); 

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
MErDFzAavTkczfuF93PRVKJxn2QREYt2sr/fOIc1KpbJ7S0XBVx+A5Ff6qyuvBcP
IFtC4bPNwETa9BtGTBO2V8d08V0ejtxeRUXYjxnRPcoN/1Grb4nqJkdY1OpBY9mo
6vBeWo04IKNWUy54sPooIoUF3/iZbIk6++6YPQWSG0k=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
hALYF/D6EU00ajx/ObGhE+3myLBc1nWoTnkdN9wTUIQPY0nn9RV3a1mnuLPMqzEt
Zy2EILppJSwnHj5tU3Gx9vzyXFK78Zo7iTWtqtqDhkA3AzRpQEla01STsnkpSo48
CSCK5W+oNVCJrRvNJHwbFqgM2g/iiKHb0F939dRO3LzOk/+GJsgsyNotaWkaRNwm
Nfv3lPPF4yjYbGSMPaA31AXxbVVyz0M+GWrclMlXMjO3kVwiWbu6KbWn7G1mq2pq
QPPRbtBd7K9hoHmK2XAIoQfXPdg5YkL/bn0BohEpPCYGigUhGwVY7bpOxAQhIYVB
HmYG/JkPyRulmzs8J8s9OA==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
MNNjURn50BqQwo8Rb7JFtgvL5Q7z0JbKT0bM5cClcUkLdz+YaDWzK6mvujk9casV
eFoa0+qI4gR11AvHQCpPqMlpXDOOZW/VpT84nN4aIzWMpLDblMuecN+5ez6jIs/R
N4wy6S6e0HRgjwbwJqgVNQCsz246LO3gqbIFcZ0Xayo=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
Szq3u3/Iy7f6Pp+OzZ9liw2BWq9fMbXt01YyfeT3VATZ0HF+QwWXT2r4lFL1hKKY
V6/ok4dJOtVfm2XBP/hItVROlFNKbKTDmxBPQPSrjQcJkpaMbOiYlzT/6gPluQRZ
OuKA6FsVAVulyMNulMopdPOSbgLmxjiemE9OZzVBOJPHNIm0lPBbN+1NLRH3YD0C
9BtWP0BTyqIvKBozPkI/JfCH6iqi/DjAOMSh0NexaVh3Bqkn9x+DFv6ITzjv3xP/
7MYfHJAaocZCav8H/CrR4RR4okGvUA4CdmbSTarCltZC1p2K1fE4QGgcf4RIqFus
HefOM7uVs3sDM0a0buA5kA==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
KeWriZZ7aX/yodA50CC3o5a8JN0EgjQitbi0D1abNw4j3GDRKujLBkAWcPMbipMD
cRFEvnquBJt1Rk/ITENYP7soTi8L5gAUXQeHN79ZOQahPgmBl9Jg7CpaB3oeXCWk
TAdsGyTTNlWGloXxBXJaoNsyifMhnzpA/qWsuQhGdbY=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 800)
`pragma protect data_block
NB677/89RFo/Bht8RTfrJheS5n6mEFnop+VITT+wZZaV2r6bu7W1yiYTNPQ5eAZf
+0UX29xyF24LIWdUP2YwrX5hpW9tFbBEqQT9Jxe5p5sjeET2rBeJDhVgS5yypzgH
tkHScel6MNEwzorDf+JUu14Hfybo7YJiYh3UPHggKprqWwgHM/ScRybVwwZj77RX
VvhvItTmBL4DxumfEmNcDyVW2qSqXsxb5Z9viRT37ZLf/aJ4VrjzlrULsNvtIQ0Z
BzWy27VUxLoAhs6o02OuD7D9it9Rf6De3D6ZFr+JtUghysTr1rtGF2r61eOTWANh
hl2otbf+h7ciekuA2mZ54728oaZU6iQxTQSHm/49tRWCI1XXWhvskURkQwjRFXEP
i6E3gzMtSxYPLLQy6GDE+t6g4vkI5/cvPK+oIFQ4i531lDBQv9m4s3AKGsFDuxwn
ohI2rQsYd68y7ek/cx+3O2LUYcdEXprLSmEUIImBLN+c4W5Zdsb/eyVhNF+bsPBo
BV30SKW4HNEXwMjPbQOybH5WR4si+5pqAY1jKMlGAUavK3gPfueRo7JmsjwdgK+D
BhPNi1j+X+53VHTxyJuXB/R5jTNShjKc0ai8xoSjf/0GZ8XMXICsb/0ptPFeLtg6
MhtwikJ4C+4nrj1qf+ALPT7snEqwZRoiOWbbCkq/vs2yuRMeMibFj+1HrqJQAYh0
YfCbHq/WS9jRKJkRg1/unvB+VrF3emE4/V1pMK20IWdDcFqg5zFxJrhbMD+GlBwf
w9AiJIS+Fhfjd9SOw+w5vPlzkTWSAVsWj5JitRuO5/JM3lqlcMB8zLWuUJYMHP8v
maJ6r8/q1Xb8NsHoH7wz3X+NyoVZv5dYIaCCd3kDPWZ+sUL3iPFFPy8jxg0HW+v5
vzCJulyTR4wFgilDKfMuSGOcxtqoY4FmD+sh9sqwucgio9+tdY+e4UnPw+HopEAu
9mUD194Ix8vvnHtTCj6B6F5rTil49F0n1fbxlZ+7C5U2so0iYTjcLxCuGaJJN6Py
yaTSlYrvo7A4G0Q6po31v+QjJikEZ21sl5rb8p44NAE=
`pragma protect end_protected
    
endmodule