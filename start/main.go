package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"

	"github.com/aws/aws-sdk-go-v2/aws/external"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
)

type Instance struct {
	ID   string
	Name string
}

func handler() error {
	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		return err
	}
	instances, err := getInstances(cfg)
	if err != nil {
		return err
	}

	names := []string{}
	for _, instance := range instances {
		log.Printf("ID: %s - Name:%s", instance.ID, instance.Name)
		names = append(names, fmt.Sprintf("ID:%s - Name:%s", instance.ID, instance.Name))
	}

	err = startInstances(cfg, instances)
	if err != nil {
		return err
	}
	postToSlack("good", "Starting the following instances:", strings.Join(names, "\n"))

	return nil
}

func main() {
	lambda.Start(handler)
}

func startInstances(cfg aws.Config, instances []Instance) error {
	instanceIds := make([]string, 0, len(instances))
	for _, instance := range instances {
		instanceIds = append(instanceIds, instance.ID)
	}

	svc := ec2.New(cfg)
	req := svc.StartInstancesRequest(&ec2.StartInstancesInput{
		InstanceIds: instanceIds,
	})
	_, err := req.Send()
	if err != nil {
		return err
	}
	return nil
}

func getInstances(cfg aws.Config) ([]Instance, error) {
	instances := make([]Instance, 0)

	svc := ec2.New(cfg)
	req := svc.DescribeInstancesRequest(&ec2.DescribeInstancesInput{
		Filters: []ec2.Filter{
			ec2.Filter{
				Name:   aws.String("tag:Environment"),
				Values: []string{os.Getenv("ENVIRONMENT")},
			},
		},
	})
	res, err := req.Send()
	if err != nil {
		return instances, err
	}

	for _, reservation := range res.Reservations {
		for _, instance := range reservation.Instances {
			for _, tag := range instance.Tags {
				if *tag.Key == "Name" {
					instances = append(instances, Instance{
						ID:   *instance.InstanceId,
						Name: *tag.Value,
					})
				}
			}
		}
	}

	return instances, nil
}
