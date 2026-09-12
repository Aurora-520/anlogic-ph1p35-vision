

module hs_detect (
    input wire     I_clk,
    input wire     I_rst_n,

    input wire     I_lp_p,
    input wire     I_lp_n,

    output reg     O_hs_en
);

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
jtisgwBKUiNL/v5nrU8PIoFNJXezpjridFAUUU/8b9cd9h441jAQsGFDXi9ScNXu
PSQqjA3A15cdyMZc23rtQ+wUSwC5w1RNZY8iCmCjKX3XeW77s/AeeLRtSoXpZbH/
dhwGerDMXoGm9NwtnWw965inhIo2bSYtCfRmh7cRoJk=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
bh4YaqwK2HT2qKZycsGUYqMjEbv1VkW3W9hYgzohwEztISyD1bHFG86zz5ykSzFi
YYrAMRRKKglRU2g50a5cXWIyceFEk5y+xAtmHmodeVkBkjq86QLEZSD011JGGTdN
XweZAZNIUJGWiJlhJDaybsp+T1nCc+zn6TgX5w/f5H0se/U4PGihP3SNbGAnH4x1
fs9oExylhOjhXSV5xB5W7m9Gf1TU+pNQjKQWMQK3rCF6wmnrywVePX3UJKhlxHKW
hefRnSfwqWN9u1WN3R9ZZljeyElxeRbpJpmmteX4zdBFcBqwMUath6PnctSxR4hV
nkS1gEm/JkmbOtdwHKM0JA==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
frFiwE8dv/WT/nvUfk6n25SKicPoHmP3BYGPPF+AFNZhiDcBpJGOnXCKHQT2wprP
mnGToWfAFOTJEEjvDrmZeYWaB49Pn+cnC9FueD5EUVF3kFbG/1W08CZzhYssdqNH
HA0rG+mRuvwdEeRZP4tGoIK7zcxUY5LNyz4G47QU4g4=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
rQC527JJVVu6DVF2f73Rn8kNA9U8+gJZb1xL8NNE9MDn0e+4ICbsBEB2Pky7akNe
tt6Pg+E50lG34MgXlu1I+Ut7Qd/4j3y+Pitrm/N0Rs03L7BOlTZMAf7fwJ/KQqtg
LaCnyhpJcZQMrL1fTGVLBmlufErVuA3SRNYjKzO51/qRssxxcnJv52oT+QNDw4ND
/RQtZkRiIkvXkBuYnXcqAI/f+P25nEJ/hi1GzvcmEysPxq5/258nzD9jvXhMWxaY
3bVStIB2n7ALJSLqA4IaOzVU2jUOh37FZ+8ZhZG4SCr+N8gEvhjKtFZJoowLRqHE
b6N7pi242dUEO/UC+PD4Rw==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
okXXfgFEnB8edH5Vir+Z+h6aHI9izK05LoT4+e3GTq+nnX1Ulk+vA0m5XVnMJzvf
jE/KE3lfvBFxI6+UzIedgVZarYsYETTWLwl3VaR+KXK5lcm3PRhoXQvbciM0qRyv
je1bm7PUTDrIZklcXgHqBSLZcjCRDW++7xmf9sIEFSM=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 2496)
`pragma protect data_block
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
`pragma protect end_protected
    
endmodule