#!/usr/bin/env bash

if [ "$1" == '/opt/sonatype/nexus/bin/nexus' ]; then
  if [ ! -f "$NEXUS_CERT/keystore.jks" ]; then
    mkdir -p $NEXUS_CERT
    if [ ! -f $NEXUS_CERT/nexus.key ]; then
      $JAVA_HOME/bin/keytool -genkeypair -alias nexus -dname "CN=$NEXUS_CERT_CN" -keystore $NEXUS_CERT/nexus.key -keypass $NEXUS_CERT_PASSWORD -storepass $NEXUS_CERT_PASSWORD
    fi
    $JAVA_HOME/bin/keytool -importkeystore -noprompt -srckeystore $NEXUS_CERT/nexus.key -srcstorepass $NEXUS_CERT_PASSWORD -destkeystore $NEXUS_CERT/keystore.jks -deststorepass $NEXUS_CERT_PASSWORD -deststoretype pkcs12
    sed -r '/<Set name="(KeyStore|KeyManager|TrustStore)Password">/ s:>.*$:>'$NEXUS_CERT_PASSWORD'</Set>:' -i $NEXUS_HOME/etc/jetty/jetty-https.xml
  fi
  mkdir -p "$NEXUS_DATA"
  chown -R nexus:nexus "$NEXUS_DATA"

  su - nexus -c "$@"
fi

exec "$@"
