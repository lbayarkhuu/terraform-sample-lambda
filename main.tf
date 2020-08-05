terraform {
  backend "remote" {
    hostname      = "app.terraform.io"
    organization  = "bayaraa_org"

    workspaces {
      prefix = "sample-lambda-function-"
    }
  }
}

variable "aws_region" {
  default = "us-west-2"
}

variable "env" {
  default = "test"
  description = "env variable define which workspaces. sample-lambda-function-test workspace store test enviroment state"
}

provider "aws" {
  region          = "${var.aws_region}"
  profile         = "default"
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "index.js"
    output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda_function.zip"
  function_name    = "tf_${var.env}_lambda"
  role             = "${aws_iam_role.iam_for_lambda_tf.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs12.x"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "tf_${var.env}_iam_for_lambda_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}