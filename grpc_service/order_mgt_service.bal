import ballerina/grpc;

// gRPC service endpoint definition.
endpoint grpc:Listener listener {
    host:"localhost",
    port:9090
};

// Order management is done using an in memory map.
// Add sample orders to the 'orderMap' at startup.
map<orderInfo> ordersMap;

// Type definition for an order.
type orderInfo record {
    string id;
    string name;
    string description;
};

// gRPC service.
@grpc:ServiceConfig
service orderMgt bind listener {

    // gRPC method to find an order.
    findOrder(endpoint caller, string orderId) {
        string payload;
        // Find the requested order from the map.
        if (ordersMap.hasKey(orderId)) {
            json orderDetails = check <json>ordersMap[orderId];
            payload = orderDetails.toString();
        } else {
            payload = "Order : '" + orderId + "' cannot be found.";
        }

        // Send response to the caller.
        _ = caller->send(payload);
        _ = caller->complete();
    }

    // gRPC method to create a new Order.
    addOrder(endpoint caller, orderInfo orderReq) {
        // Add the new order to the map.
        string orderId = orderReq.id;
        ordersMap[orderReq.id] = orderReq;
        // Create a response message.
        string payload = "Status : Order created; OrderID : " + orderId;

        // Send a response to the caller.
        _ = caller->send(payload);
        _ = caller->complete();
    }

    // gRPC method to update an existing Order.
    updateOrder(endpoint caller, orderInfo updatedOrder) {
        string payload;
        // Find the order that needs to be updated.
        string orderId = updatedOrder.id;
        if (ordersMap.hasKey(orderId)) {
            // Update the existing order.
            ordersMap[orderId] = updatedOrder;
            payload = "Order : '" + orderId + "' updated.";
        } else {
            payload = "Order : '" + orderId + "' cannot be found.";
        }

        // Send a response to the caller.
        _ = caller->send(payload);
        _ = caller->complete();
    }

    // gRPC method to delete an existing Order.
    cancelOrder(endpoint caller, string orderId) {
        string payload;
        if (ordersMap.hasKey(orderId)) {
            // Remove the requested order from the map.
            _ = ordersMap.remove(orderId);
            payload = "Order : '" + orderId + "' removed.";
        } else {
            payload = "Order : '" + orderId + "' cannot be found.";
        }

        // Send a response to the caller.
        _ = caller->send(payload);
        _ = caller->complete();
    }
}