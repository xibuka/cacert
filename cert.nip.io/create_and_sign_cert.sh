export PATH=$PATH:.
cat > ${1}-csr.json <<EOF
{
  "CN": "${1}.nip.io",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "JP",
      "L": "Tokyo",
      "O": "WenhandotAi",
      "OU": "Lab",
      "ST": "Tokyo"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  -hostname "${1}.nip.io" \
  ${1}-csr.json | cfssljson -bare ${1}
