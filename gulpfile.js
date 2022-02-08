var gulp = require('gulp');
var runSequence = require('run-sequence');
var sonarqubeScanner = require('sonarqube-scanner');
var request = require('ajax-request');
var sleep = require('sleep');
var os = require('os');

const sonar_server = 'http://192.168.1.161';
var project_key="";
var project_name="";
// fetch command line arguments
const arg = (argList => {
		let arg = {}, a, opt, thisOpt, curOpt;
for(a=0;a<argList.length;a++)thisOpt=argList[a].trim(),opt=thisOpt.replace(/^\-+/,""),opt===thisOpt?(curOpt&&(arg[curOpt]=opt),curOpt=null):(curOpt=opt,arg[curOpt]=!0);
return arg;
})(process.argv);

function waitTask(){
	sleep.sleep(5)
	request({
		url: sonar_server+'/api/ce/component?component=' + project_key,
		method: 'GET',
		json: true,
		async: false
	}, function (err, res, body) {
		console.log(body);
		if(body.queue.length != 0){
			waitTask()
		}else{
			getQualityGate()
		}
	});
}

function getQualityGate(){
	request({
		url: sonar_server+'/api/qualitygates/project_status?projectKey=' + project_key,
		method: 'GET',
		json: true
	}, function (err, res, body) {
		console.log(body.projectStatus.status);
		//console.log(body[0].msr[0].data);
	});
}

function bumpVersion(str) {
	var tab = str.split(".");
	return (version = tab[0] + "." + tab[1] + "." + (parseInt(tab[2]) + 1));
}

gulp.task('sonar-scanner', function (callback) {
	var project_version;
	project_key = arg.project+"."+process.env.DEV_USERNAME;
	project_name = arg.project+"."+process.env.DEV_USERNAME;
	request({
		url: sonar_server+'/api/project_analyses/search?project=' + project_key,
		method: 'GET',
		json: true,
		async: false
	}, function (err, res, body) {
		try{
			if(body.analyses.length > 0){
				var previous_version;
				body.analyses[0].events.forEach(function(object){
					if(object.category =="VERSION"){
						previous_version = object.name;
					}
				});
				project_version = bumpVersion(previous_version);
			}
		}catch (err){
			project_version = "99.99.0";
		}
        
		sonarqubeScanner({
			serverUrl: sonar_server,
			options: {
				"sonar.projectKey": project_key,
				"sonar.projectName": project_name,
				"sonar.projectVersion": project_version,
				"sonar.sourceEncoding": "UTF-8",
				"sonar.sources": arg.file
			}
		}, callback);
		console.log('waiting SonarQube Task');
		waitTask();
	});
});


gulp.task('dev-task-runner-v1', function() {
	runSequence(
		'sonar-scanner'
	);
});