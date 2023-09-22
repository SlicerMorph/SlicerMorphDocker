#list servers
list.cmd = paste("openstack server list")
servers = system(list.cmd, intern=TRUE)

split.name=function(X){
  temp = strsplit(X, "|", fixed=TRUE)
  return(temp[[1]][3])
}
split.status=function(X){
  temp = strsplit(X, "|", fixed=TRUE)
  return(temp[[1]][4])
}
split.UUID=function(X){
  temp = strsplit(X, "|", fixed=TRUE)
  return(temp[[1]][2])
}

dat=workshop=NULL
for (i in 4:(length(servers)-1)) if (strtrim(split.name(servers[i]), 9) == " workshop") workshop=c(workshop, i)

ip = "openstack server show -c addresses"
pass = "openstack server show --os-compute-api-version=2.26 -c tags -f shell"

url1='https://http'
url2='49528.proxy-js2-iu.exosphere.app/guacamole/#/client/ZGVza3RvcABjAGRlZmF1bHQ'


for (i in 1:length(workshop)) {
  t1=system(paste(pass, split.UUID(servers[workshop[i]])), intern=TRUE)
  pass.phr=substr(strsplit(t1, "'", fixed=TRUE)[[1]][2], 7, 100)
  t2=system(paste(ip, split.UUID(servers[workshop[i]])), intern=TRUE)
  system.ip = strsplit(strsplit(t2[4], ",")[[1]][2], "|", fixed=TRUE)[[1]][1]
  t3=gsub(" ", '-', system.ip, fixed=TRUE)
  t3=gsub(".", "-", t3, fixed=TRUE)
  dat = rbind(dat, cbind(pass.phr, system.ip, paste0(url1,t3,url2)))
}
