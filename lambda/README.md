# File index

- `AMIRefresher.js` is a Node.JS script that will automatically create an AMI from your current Archive node instance and update your autoscaling group, so you will have the relevant images to scale or to recover from disaster. Parts of it's code may also be useful for those who search how to copy existing launch configuration in Node.JS. This scripts supposes you have setup the following environment variables:
  - `ASGName` - the name of your autoscaling group;
  - `AMIInstanceID` - id of your Archive node instance;
  - `LCName` - a name of launch configuration to be created;
  - `ONLY_AMI_CREATION` - set to true if you want script to simply create an AMI (assignment and old image deletion will not be performed in that case);

