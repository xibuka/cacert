#/bin/bash

if [ ! -e cfssl ]; then
    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    mv cfssl_linux-amd64 cfssl
    chmod 755 cfssl 
fi
if [ ! -e cfssljson ]; then
    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    mv cfssljson_linux-amd64 cfssljson
    chmod 755 cfssljson
fi

export PATH=$PATH:.

cat <<EOF >ca-config.json
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "kubernetes": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF
cat <<EOF >ca-csr.json
{
    "CN": "WenhandotCA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "JP",
            "L": "Tokyo",
            "O": "WenhandotCA",
            "OU": "Lab",
            "ST": "Tokyo"
        }
    ]
}
EOF
cat > global-csr.json <<EOF
{
  "CN": "*.nip.io",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "JP",
      "L": "Tokyo",
      "O": "WenhandotCA",
      "OU": "Lab",
      "ST": "Tokyo"
    }
  ]
}
EOF
cfssl gencert -initca ca-csr.json |cfssljson -bare ca

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  global-csr.json | cfssljson -bare global
