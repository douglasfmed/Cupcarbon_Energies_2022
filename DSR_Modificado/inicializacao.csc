///////////////////////////////////////////////////////////////////
//                                                               //
// Simulacao do protocolo DSR (Dynamic Source Routing)			 //
// Descricao: Topologia simples                                  //
// Autor: Douglas de Farias Medeiros						     //
// 																 //
// Orientador: 	 Prof. Dr. Cleonilson Protasio de Souza			 //
// Coorientador: Prof. Dr. Fabricio Braga Soares de Carvalho     //
//																 //
// Universidade Federal da Paraiba (UFPB)						 //
// Mestrado em Engenharia Eletrica 								 //
// Laboratorio de Microengenharia								 //
//																 //
///////////////////////////////////////////////////////////////////

// X = Infinito
//set dest 7

// DEFINICOES INICIAIS //////////////////////////////////////////////////////////////////
atget id meu_id 	// Obter o proprio endereco
set n_nos 25 		// Numero total de nos da rede

set etapa 1 		// Seta etapa inicial (da atividade 1)
set vazio \ 		// Define uma variavel vazia para comparacao
set ultimo_n_vizinhos 0

set tempo_tx 30

set rreq_id 0
set ultima_rreq_recebida 0

set qtd_msgs_enviadas 0
set qtd_msgs_recebidas 0
set delay_medio 0
set soma_delay 0
set trava_tempo_primeira_msg 0
set contador_nrl 0

set delay_anterior 0
set soma_jitter 0

// CRIACAO DA TABELA DE ROTEAMENTO ////////////////////////////////////////////////////
// Coluna 1 = ID dos destinos
// Coluna 2 = Melhor rota 
// Coluna 3 = Potencia de TX

// Tabela de roteamento de cada no
tab vizinhos $n_nos 3 		

// ALOCACAO INICIAL DOS DADOS ///////////////////////////////////////////////////////////

for i 0 $n_nos
	set id ($i+1)
	int id $id

	tset $id vizinhos $i 0
	if($id==$meu_id)
		tset $meu_id vizinhos $i 1
		tset 10 vizinhos $i 2
	else
		tset x vizinhos $i 1
		tset x vizinhos $i 2
	end
	
	// Setando potencia de TX maxima inicialmente
	//tset 100 vizinhos $i 2
	
end 

// Inicializando a potencia de TX
atpl 100

mark 0 				// Desliga o destaque do no inicialmente

// Definicoes de mobilidade
set libera_trajeto 0
set tempo_pausa 60
set trajeto 1
set prox_trajeto 1
set ponto 0
set trava_primeira_posicao 0

// Velocidade dos nos sensores em m/s
set velocidade 50

// Definicao das tabelas com as coordenadas das rotas 
// Coluna 1 = Longitude
// Coluna 2 = Latitude
// Linhas = Quantidade de pontos da rota

tab rota_1 5 2
tab rota_2 7 2
tab rota_3 11 2

// Informacoes sobre a rota 1 ///////////////////
tset -34.877440 rota_1 0 0
tset -7.114682 rota_1 0 1

tset -34.874211 rota_1 1 0
tset -7.115278 rota_1 1 1

tset -34.873750 rota_1 2 0
tset -7.115534 rota_1 2 1

tset -34.867892 rota_1 3 0
tset -7.119856 rota_1 3 1

tset -34.823697 rota_1 4 0
tset -7.119409 rota_1 4 1

// Informacoes sobre a rota 2 ///////////////////
tset -34.845197 rota_2 0 0
tset -7.119620 rota_2 0 1

tset -34.845369 rota_2 1 0
tset -7.126050 rota_2 1 1

tset -34.849506 rota_2 2 0
tset -7.128908 rota_2 2 1

tset -34.854055 rota_2 3 0
tset -7.132954 rota_2 3 1

tset -34.853583 rota_2 4 0
tset -7.137638 rota_2 4 1

tset -34.852253 rota_2 5 0
tset -7.139767 rota_2 5 1

tset -34.851207 rota_2 6 0
tset -7.143316 rota_2 6 1

// Informacoes sobre a rota 3 ///////////////////
tset -34.851878 rota_3 0 0
tset -7.140817 rota_3 0 1

tset -34.850376 rota_3 1 0
tset -7.136899 rota_3 1 1

tset -34.854067 rota_3 2 0
tset -7.137623 rota_3 2 1

tset -34.860293 rota_3 3 0
tset -7.133720 rota_3 3 1

tset -34.859221 rota_3 4 0
tset -7.132698 rota_3 4 1

tset -34.860079 rota_3 5 0
tset -7.130058 rota_3 5 1

tset -34.872868 rota_3 6 0
tset -7.124650 rota_3 6 1

tset -34.869606 rota_3 7 0
tset -7.118006 rota_3 7 1

tset -34.874193 rota_3 8 0
tset -7.115251 rota_3 8 1

tset -34.877369 rota_3 9 0
tset -7.114782 rota_3 9 1

tset -34.877603 rota_3 10 0
tset -7.113771 rota_3 10 1

if($meu_id==1)
	script principal_TX
else
	script principal_RX
end 