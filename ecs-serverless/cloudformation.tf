resource "aws_cloudformation_stack" "tf-outputs" {
  name          = "tf-outputs"
  template_body = <<STACK
{
  "Resources": {
    "ApiGatewayId": {
      "Type" : "AWS::SSM::Parameter",
      "Properties": {
        "Name": "api-gateway-id",
        "Type": "String",
        "Value": "${aws_api_gateway_rest_api.timetable-solver-api.id}"
      }
    },
    "ApiGatewayRootId": {
      "Type" : "AWS::SSM::Parameter",
      "Properties": {
        "Name": "api-gateway-root-id",
        "Type": "String",
        "Value": "${aws_api_gateway_rest_api.timetable-solver-api.root_resource_id}"
      }
    }
  },
  "Outputs": {
    "ApiGatewayId": {
        "Value": "${aws_api_gateway_rest_api.timetable-solver-api.id}"
    },
    "ApiGatewayRootId": {
      "Value": "${aws_api_gateway_rest_api.timetable-solver-api.root_resource_id}"
    }
  }
}
STACK
}
