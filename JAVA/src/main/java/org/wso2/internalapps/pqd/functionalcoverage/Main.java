package org.wso2.internalapps.pqd.functionalcoverage;

public class Main {
    public static void main(String [] args){
        int ret= TestResultFromTestLink.saveFunctionalCoveragetoDB();
        if(ret==0){
            System.out.println("ERROR");
        }
    }
}
