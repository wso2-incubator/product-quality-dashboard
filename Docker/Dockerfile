FROM java
MAINTAINER Sajitha Liyanage <sajithal@wso2.com

# Update packages and install dependencies.
ENV hostname wso2internaldev-engineering-dashboard.wso2apps.com
ENV balhostname 192.168.56.2:9092
RUN  mkdir -p /wso2
COPY dist/wso2das-3.1.0.zip /wso2
RUN cd /wso2 && \
    unzip wso2das-3.1.0.zip && \
    rm wso2das-3.1.0.zip
COPY bootstrap.sh /wso2/wso2das-3.1.0/bin    

RUN useradd -ms /bin/bash wso2user \
    && chown -R wso2user /wso2 \
    && chmod -R 0774 /wso2
USER wso2user

ENTRYPOINT ["/wso2/wso2das-3.1.0/bin/bootstrap.sh"]
#CMD /wso2/wso2ds-2.0.0/bin/wso2server.sh -Dhttpclient.hostnameVerifier=AllowAll

EXPOSE 9763 9443 8280 8243
