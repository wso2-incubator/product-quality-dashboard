package org.mongoconnector.service;

import com.mongodb.*;

import java.io.IOException;

public class MongoDbConnector {

    public String getReasonsFromDatabase(String component, int buildNumber){
        // Creating Credentials
        String result = null;
        Configuration conf = new Configuration();
        ReaderYml read = new ReaderYml();
        try{
            conf = read.readYaml();
        }catch (IOException e){

        }

        try{
            String userName  = conf.getUserName();
            String password = conf.getPassword();
            String mongoServer = conf.getMongoServer();
            String mongoDB = conf.getMongoDB();

            String currentURI = "mongodb://"+userName+":"+password+"@"+mongoServer+"/"+mongoDB;

            MongoClientURI uri  = new MongoClientURI(currentURI);
            MongoClient client = new MongoClient(uri);

            DB db = client.getDB("Build_Failure");
            DBCollection table = db.getCollection("statistics");

            //add select fields from documents
            BasicDBObject fields = new BasicDBObject();
            fields.put("buildNumber", 1);
            fields.put("projectName", 1);
            fields.put("failureCauses", 1);
            fields.put("result", 1);

            //add where filters for document
            BasicDBObject regexQuery = new BasicDBObject();
            regexQuery.put("buildNumber",buildNumber);
            regexQuery.put("result",new BasicDBObject("$ne","SUCCESS"));
            regexQuery.put("projectName",new BasicDBObject("$regex", ".*"+component+".*"));

            DBCursor cursor = table.find(regexQuery,fields);

            //set order to desceding
            BasicDBObject order = new BasicDBObject();
            order.put("_id", -1);
            cursor.sort(order);
            cursor.limit(1);

            if(cursor.size()>0) {
                result = cursor.next().toString();
            }else{
                System.out.println("NO ANY RELATED DOCUMENT IN MONGODB");
                result = "null";
            }

        }catch (Exception e){
            System.out.println("ERROR");
            System.out.println(e);
        }


        return result;
    }

    public String getFailureCategory(String pattern){
        String result = null;
        Configuration conf = new Configuration();
        ReaderYml read = new ReaderYml();
        try{
            conf = read.readYaml();
        }catch (IOException e){

        }

        try{
            String userName  = conf.getUserName();
            String password = conf.getPassword();
            String mongoServer = conf.getMongoServer();
            String mongoDB = conf.getMongoDB();
            String currentURI = "mongodb://"+userName+":"+password+"@"+mongoServer+"/"+mongoDB;

            MongoClientURI uri  = new MongoClientURI(currentURI);
            MongoClient client = new MongoClient(uri);

            DB db = client.getDB("Build_Failure");
            DBCollection table = db.getCollection("failureCauses");

            //add select fields from documents
            BasicDBObject fields = new BasicDBObject();
            fields.put("categories", 1);

            //add where filters for document
            BasicDBObject regexQuery = new BasicDBObject();
            regexQuery.put("indications.pattern",pattern);

            DBCursor cursor = table.find(regexQuery,fields);
            cursor.limit(1);

            if(cursor.size()>0) {
                result = cursor.next().toString();
            }else{
                System.out.println("NO ANY RELATED CATEGORY DOCUMENT IN MONGODB");
                result = "UNKNOWN";
            }

        }catch (Exception e){
            System.out.println("ERROR");
            System.out.println(e);
        }


        return result;
    }

}
