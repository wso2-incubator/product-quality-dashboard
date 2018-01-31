package org.mongoconnector.service;

import com.esotericsoftware.yamlbeans.YamlReader;

import java.io.FileReader;
import java.io.IOException;

public class ReaderYml {

    public Configuration readYaml() throws IOException{

        YamlReader reader = new YamlReader(new FileReader("/home/sajitha/Documents/Jenkins_Build_Breaks/Mongodb-Service/src/main/resources/config.yml"));

        Configuration remoteRepoConfigurations= reader.read(Configuration.class);

        return remoteRepoConfigurations;
    }
}
