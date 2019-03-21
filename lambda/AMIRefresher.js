var aws = require('aws-sdk');
var https = require('https');
var url = require('url');
var util = require("util");

var ASGName = process.env.ASGName;
var AMIInstanceID = process.env.AMIInstanceID; 
var LCName= process.env.LCName; 
var OnlyAMICreation=process.env.ONLY_AMI_CREATION;
var AMIName =process.env.AMIName;

exports.handler = function(event, context, callback)  {
    var ec2 = new aws.EC2();
    var autoscaling = new aws.AutoScaling();
    
	// Create unique AMI and launch configuration names
    var date = new Date(); 
    var timestamp = date.getTime();
    AMIName = AMIName+timestamp;
	LCName = LCName+timestamp;
    var AMIID, LC, OldASG;
    
	// Either simply create an image or execute the whole function
    if (OnlyAMICreation) { createImage(); }
    else { describeASG(); }
    
	// Get info about autoscaling groups and proceed to get info about Launch configuration
    function describeASG()
    {
        var params = {
          AutoScalingGroupNames: [
             ASGName
          ]
         };
         
         autoscaling.describeAutoScalingGroups(params, function(err, data) {
           if (err) console.log("Error", err, err.stack); // an error occurred
           else OldASG=data; describeLC();      // successful response
         });
    }
     
	// Get info about launch configuration and proceed to AMI creation
    function describeLC()
    {
        var params = {
          LaunchConfigurationNames: [
             OldASG.AutoScalingGroups[0].LaunchConfigurationName
          ]
        };
        autoscaling.describeLaunchConfigurations(params, function(err, data) {
           if (err) console.log(err, err.stack); // an error occurred
           else { LC=data; createImage(); }     // successful response
        });
    }
    
	// Create AMI and either proceed to create a new launch configuration or exit function
    function createImage()
    {
        var params = {
         Description: "Created by AMIRefresher function", 
         InstanceId: AMIInstanceID, 
         Name: AMIName, 
         NoReboot: true
        };

        ec2.createImage(params, function(err, data) {
         if (err) console.log("Error!", err, err.stack); // an error occurred
         else if (OnlyAMICreation) { process.exit(0); }
         else { AMIID=data; createLC(); }         // successful response
        });
    }

	// Create new launch configuration and proceed to update an autoscaling group
    function createLC()
    {
        var params = {
          LaunchConfigurationName: LCName, 
          AssociatePublicIpAddress: LC.LaunchConfigurations[0].AssociatePublicIpAddress,
          BlockDeviceMappings: LC.LaunchConfigurations[0].BlockDeviceMappings,
          ClassicLinkVPCId: LC.LaunchConfigurations[0].ClassicLinkVPCId,
          ClassicLinkVPCSecurityGroups: LC.LaunchConfigurations[0].ClassicLinkVPCSecurityGroups,
          EbsOptimized: LC.LaunchConfigurations[0].EbsOptimized,
          IamInstanceProfile: LC.LaunchConfigurations[0].IamInstanceProfile,
          ImageId: AMIID.ImageId,
          InstanceMonitoring: LC.LaunchConfigurations[0].InstanceMonitoring,
          InstanceType: LC.LaunchConfigurations[0].InstanceType,
          KeyName: LC.LaunchConfigurations[0].KeyName,
          PlacementTenancy: LC.LaunchConfigurations[0].PlacementTenancy,
          SecurityGroups: LC.LaunchConfigurations[0].SecurityGroups,
          UserData: LC.LaunchConfigurations[0].UserData
        };
        autoscaling.createLaunchConfiguration(params, function(err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else  updateASG();          // successful response
        });
    }
    
	// update an autoscaling group and proceed to cleanup
    function updateASG()
    {
		var params = {
		  AutoScalingGroupName: ASGName, 
		  LaunchConfigurationName: LCName
		};
		autoscaling.updateAutoScalingGroup(params, function(err, data) {
		   if (err) console.log(err, err.stack); // an error occurred
		   else     clean();          // successful response
		});
    }
    
	// Cleanup and exit - delete old launch configuration and old AMI
    function clean()
    {
        var params = {
          LaunchConfigurationName: OldASG.AutoScalingGroups[0].LaunchConfigurationName
        };
        autoscaling.deleteLaunchConfiguration(params, function(err, data) {
           if (err) console.log(err, err.stack); // an error occurred
           else     console.log(data);           // successful response
        });
         
        var params = {
          ImageId: LC.LaunchConfigurations[0].ImageId, 
        };
        ec2.deregisterImage(params, function(err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else     console.log(data);           // successful response
        });
    }
};
