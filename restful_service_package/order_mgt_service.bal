import ballerina/http;
import ballerinax/docker;
import ballerina/log;
import ballerina/grpc;
import dalong/petstore;
@docker:Config {
    registry:"dalongrong",
    name:"restful_service",
    tag:"v1.0"
}
endpoint http:Listener listener {
    port:9093
};
// Order management is done using an in memory map.
// Add some sample orders to 'ordersMap' at startup.
map<json> ordersMap;

 endpoint orderMgtBlockingClient orderMgtBlockingEp {
        url:"http://localhost:9090"
 };
// RESTful service.
@http:ServiceConfig { basePath: "/ordermgt" }
service<http:Service> orderMgt bind listener {

   @http:ResourceConfig {
        methods: ["GET"],
        path: "/grpc/{orderId}"
    }
    grpc(endpoint client, http:Request req, string orderId) {
     // Find an order
    log:printInfo("---------------------Find an existing order---------------------");
    var findResponse = orderMgtBlockingEp->findOrder(orderId);
    match findResponse {
        (string, grpc:Headers) payload => {
            string result;
            grpc:Headers resHeaders;
            (result, resHeaders) = payload;
            log:printInfo("Response - " + result + "\n");
            _ = client->respond(result);
        }
        error err => {
            log:printError("Error from Connector: " + err.message + "\n");
        }
    }
    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/app"
    }
    petinfo(endpoint client, http:Request req) {
         petstore:Pet p = {id:"dalong",category:"dddd",name:"demo name"};
         _ = client->respond(check  <json>p);
    }
    // Resource that handles the HTTP GET requests that are directed to a specific
    // order using path '/order/<orderId>'.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/order/{orderId}"
    }
    findOrder(endpoint client, http:Request req, string orderId) {
        // Find the requested order from the map and retrieve it in JSON format.
        json? payload = ordersMap[orderId];
        http:Response response;
        if (payload == null) {
            payload = "Order : " + orderId + " cannot be found.";
        }

        // Set the JSON payload in the outgoing response message.
        response.setJsonPayload(untaint payload);

        // Send response to the client.
        _ = client->respond(response);
    }

    // Resource that handles the HTTP POST requests that are directed to the path
    // '/order' to create a new Order.
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/order"
    }
    addOrder(endpoint client, http:Request req) {
        json orderReq = check req.getJsonPayload();
        string orderId = orderReq.Order.ID.toString();
        ordersMap[orderId] = orderReq;

        // Create response message.
        json payload = { status: "Order Created.", orderId: orderId };
        http:Response response;
        response.setJsonPayload(untaint payload);

        // Set 201 Created status code in the response message.
        response.statusCode = 201;
        // Set 'Location' header in the response message.
        // This can be used by the client to locate the newly added order.
        response.setHeader("Location", "http://localhost:9090/ordermgt/order/" +
                orderId);

        // Send response to the client.
        _ = client->respond(response);
    }

    // Resource that handles the HTTP PUT requests that are directed to the path
    // '/order/<orderId>' to update an existing Order.
    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/order/{orderId}"
    }
    updateOrder(endpoint client, http:Request req, string orderId) {
        json updatedOrder = check req.getJsonPayload();

        // Find the order that needs to be updated and retrieve it in JSON format.
        json existingOrder = ordersMap[orderId];

        // Updating existing order with the attributes of the updated order.
        if (existingOrder != null) {
            existingOrder.Order.Name = updatedOrder.Order.Name;
            existingOrder.Order.Description = updatedOrder.Order.Description;
            ordersMap[orderId] = existingOrder;
        } else {
            existingOrder = "Order : " + orderId + " cannot be found.";
        }

        http:Response response;
        // Set the JSON payload to the outgoing response message to the client.
        response.setJsonPayload(untaint existingOrder);
        // Send response to the client.
        _ = client->respond(response);
    }

    // Resource that handles the HTTP DELETE requests, which are directed to the path
    // '/order/<orderId>' to delete an existing Order.
    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/order/{orderId}"
    }
    cancelOrder(endpoint client, http:Request req, string orderId) {
        http:Response response;
        // Remove the requested order from the map.
        _ = ordersMap.remove(orderId);

        json payload = "Order : " + orderId + " removed.";
        // Set a generated payload with order status.
        response.setJsonPayload(untaint payload);

        // Send response to the client.
        _ = client->respond(response);
    }
}