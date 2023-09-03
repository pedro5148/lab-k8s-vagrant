# Laboratorio Kubernetes no Vagrant

Ajustei esses script do Vagrant para criar um cluster local do Kubernetes no VirtualBox para fins educacionais com base no projeto do Caio Delgado [blog-vagrant-101](https://github.com/caiodelgadonew/blog-vagrant-101)

## Dependências
1 - VirtualBox (versão usada 6.1.46r158378)

2 - Vagrant (versão usada 2.2.19)

## Iniciando
Com todos os arquivos na mesma pasta, execute o comando `$ vagrant up`

## Funcionamento
Apos executar o comando acima, o vagrant ira criar um cluster com 3 máquina (1 control-plane e 2 worker's) conforme informado no trecho abaixo:
```Ruby
machines = {
"master" => {"memory" => "2048", "cpu" => "2", "ip" => "110", "image" => "ubuntu/jammy64"},
"worker01" => {"memory" => "2048", "cpu" => "2", "ip" => "111", "image" => "ubuntu/jammy64"},
"worker02" => {"memory" => "2048", "cpu" => "2", "ip" => "112", "image" => "ubuntu/jammy64"},
}
```
Neste trecho, a variável *machines* recebe um `hash` com as configurações da máquina.
Essas configurações podem ser alteradas conforme necessidade, inclusive a quantidade de máquinas.

Ao fim do *deploy* das máquinas, o Vagrant ira executar um *script* de instalação de todos os pacotes necessarios para o *cluster* conform trecho abaixo
```Ruby
if  "#{name}"  ==  "master"
	machine.vm.provision "shell", path: "data/master.sh"
else
	machine.vm.provision "shell", path: "data/worker.sh"
end
```
O script para o *control-plane* ė diferente do *worker*, por isso a condicional `if` executa o script correto de cada.

## Importante
1. Reinicie o cluster para efetivar as mudanças `$vagrant reload`
 
2. Para que o *cluster* funcione corretamente, adicionei o trecho abaixo para sempre definir o *gateway* do *cluster*, com o mesmo *gateway* do host, pois o Vagrant define a rota principal como sendo a propria rede (*10.0.2.2*), e por isso ao executar o comando `kubeadm init`  o cluster não inicia corretamente.
```Ruby
config.vm.provision "shell",
	run: "always",
inline: "ip route add default via #$DEFAULT_GW"