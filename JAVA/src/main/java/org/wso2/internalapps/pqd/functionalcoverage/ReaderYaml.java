package org.wso2.internalapps.pqd.functionalcoverage;

import com.esotericsoftware.yamlbeans.YamlReader;

import java.io.FileReader;
import java.io.IOException;

public class ReaderYaml {
    public Config readYaml() throws IOException{

        YamlReader reader = new YamlReader(new FileReader("/home/asha/IdeaProjects/testlinkjavaapi/src/main/resources/ConfigFile.yml"));

        Config remoteRepoConfigurations= reader.read(Config.class);

        return remoteRepoConfigurations;
    }

}