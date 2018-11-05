import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/swagger;
import ballerinax/docker;

@docker:Config {
    registry:"dalongrong",
    name:"petstore",
    tag:"v1.0"
}

@docker:Expose{}
endpoint http:Listener ep0 { 
    port: 9095
};

@swagger:ServiceInfo { 
    title: "Ballerina Petstore",
    description: "This is a sample Petstore server. This uses swagger definitions to create the ballerina service",
    serviceVersion: "1.0.0",
    termsOfService: "http://ballerina.io/terms/",
    contact: {name: "", email: "samples@ballerina.io", url: ""},
    license: {name: "Apache 2.0", url: "http://www.apache.org/licenses/LICENSE-2.0.html"},
    tags: [
        {name: "pet", description: "Everything about your Pets", externalDocs: {description: "Find out more", url: "http://ballerina.io"}}
    ],
    externalDocs: {description: "Find out more about Ballerina", url: "http://ballerina.io"}
}
@http:ServiceConfig {
    basePath: "/v1"
}
service BallerinaPetstore bind ep0 {

    @swagger:ResourceInfo {
        summary: "Update an existing pet",
        tags: ["pet"]
    }
    @http:ResourceConfig { 
        methods:["PUT"],
        path:"/pet",
        body:"_updatePetBody"
    }
    updatePet (endpoint outboundEp, http:Request _updatePetReq, Pet _updatePetBody) { 
        http:Response _updatePetRes = updatePet(_updatePetReq, _updatePetBody);
        outboundEp->respond(_updatePetRes) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        summary: "Add a new pet to the store",
        tags: ["pet"]
    }
    @http:ResourceConfig { 
        methods:["POST"],
        path:"/pet",
        body:"_addPetBody"
    }
    addPet (endpoint outboundEp, http:Request _addPetReq, Pet _addPetBody) { 
        http:Response _addPetRes = addPet(_addPetReq, _addPetBody);
        outboundEp->respond(_addPetRes) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        summary: "Find pet by ID",
        tags: ["pet"],
        description: "Returns a single pet",
        parameters: [
            {
                name: "petId",
                inInfo: "path",
                description: "ID of pet to return", 
                required: true, 
                allowEmptyValue: ""
            }
        ]
    }
    @http:ResourceConfig { 
        methods:["GET"],
        path:"/pet/{petId}"
    }
    getPetById (endpoint outboundEp, http:Request _getPetByIdReq, string petId) { 
        http:Response _getPetByIdRes = getPetById(_getPetByIdReq, petId);
        outboundEp->respond(_getPetByIdRes) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        summary: "Deletes a pet",
        tags: ["pet"],
        parameters: [
            {
                name: "petId",
                inInfo: "path",
                description: "Pet id to delete", 
                required: true, 
                allowEmptyValue: ""
            }
        ]
    }
    @http:ResourceConfig { 
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    deletePet (endpoint outboundEp, http:Request _deletePetReq, string petId) { 
        http:Response _deletePetRes = deletePet(_deletePetReq, petId);
        outboundEp->respond(_deletePetRes) but { error e => log:printError("Error while responding", err = e) };
    }

}
