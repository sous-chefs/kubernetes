kube_pod "yup" do
  action :nothing
end

kube_service "redis-master" do
  port 500
  action [:destroy,:create]
  labels ['aww=yiss','this=is-awesome']
end

kube_service "redis-blah-blah" do
  port 1234
  container_port 5532
  action [:destroy,:create]
  labels 'aww' => 'yiss'
  selector 'aww=yiss'
end


kube_pod "test-group" do
  containers({
    name: 'redis-master',
    image: 'dockerfile/redis'
  })
  labels "aww=yiss"
  action [:destroy,:create]
end

kube_replication_controller "this-controls-the-things" do
  containers({
    name: 'controlled-by-the-things',
    image: 'dockerfile/redis'
  })
  pod_labels 'app=thisthing'
  selector 'controlled-by=thethings'
  replicas 2
  labels 'yup' => 'the-things'
  action [:destroy,:create]
end