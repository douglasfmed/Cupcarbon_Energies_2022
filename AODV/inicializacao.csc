///////////////////////////////////////////////////////////////////
//                                                               //
// Simulacao do protocolo AODV (Ad-hoc On Demand)				 //
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

set delay_TX 5 		// Delay geral do codigo

set atividade 1 	// Seta atividade inicial
set etapa 1 		// Seta etapa inicial (da atividade 1)
//set verifica 90   // Ignorar esta variavel por enquanto
set vazio \ 		// Define uma variavel vazia para comparacao
mark 0 				// Desliga o destaque do no inicialmente
set info_repetida 0 // Variavel que armazena o numero de informacoes repetidas no no
set verifica 15
set ultimo_n_vizinhos 0
set periodo_TX 5

set tempo_tx 30

set libera_TX 0

set delay_anterior 0
set soma_jitter 0

set libera_trajeto 0
set trajeto 1
set prox_trajeto 1
set ponto 0

set trava_primeira_posicao 0

set qtd_msgs_enviadas 0
set qtd_msgs_recebidas 0
set delay_medio 0
set soma_delay 0
set trava_tempo_primeira_msg 0

set tempo_pausa 60
// Velocidade dos nos sensores em m/s
set velocidade 5

// Definicao das tabelas com as coordenadas das trajetos 
// Coluna 1 = Longitude
// Coluna 2 = Latitude
// Linhas = Quantidade de pontos da trajeto

tab trajeto_1 5 2
tab trajeto_2 7 2
tab trajeto_3 11 2

// CRIACAO DAS TABELAS DE ROTEAMENTO ////////////////////////////////////////////////////
// Coluna 1 = ID
// Coluna 2 = Custo
// Coluna 3 = Proximo salto
// Coluna 4 = Numero de sequencia

tab vizinhos $n_nos 4 		    // Tabela de roteamento de cada no
tab vizinhos_recebidos $n_nos 4 // Tabela temporaria de vizinhos recebidos
tab RREQ_ID_TAB $n_nos 1        // Tabela com a ultima RREQ de cada no

// ALOCACAO INICIAL DOS DADOS ///////////////////////////////////////////////////////////
// custo_proprio = 0, NS_proprio = 2
// custo_vizinhos = x, NS_vizinhos = 0 (todos desconhecidos ainda)

for i 0 $n_nos
	set id_inicio ($i+1)
	int id_inicio $id_inicio
	tset $id_inicio vizinhos $i 0
	tset $id_inicio vizinhos_recebidos $i 0
	if($id_inicio==$meu_id)
		tset 0 vizinhos $i 1
		tset $meu_id vizinhos $i 2
		tset 2 vizinhos $i 3
	else
		tset x vizinhos $i 1
		tset x vizinhos $i 2
		tset 0 vizinhos $i 3
	end
	
	// ALOCACAO INICIAL DOS DADOS DA TABELA DE RREQ
	tset 0 RREQ_ID_TAB $i 0
end 

// Informacoes sobre a trajeto 1 ///////////////////
tset -34.877440 trajeto_1 0 0
tset -7.114682 trajeto_1 0 1

tset -34.874211 trajeto_1 1 0
tset -7.115278 trajeto_1 1 1

tset -34.873750 trajeto_1 2 0
tset -7.115534 trajeto_1 2 1

tset -34.867892 trajeto_1 3 0
tset -7.119856 trajeto_1 3 1

tset -34.823697 trajeto_1 4 0
tset -7.119409 trajeto_1 4 1

// Informacoes sobre a trajeto 2 ///////////////////
tset -34.845197 trajeto_2 0 0
tset -7.119620 trajeto_2 0 1

tset -34.845369 trajeto_2 1 0
tset -7.126050 trajeto_2 1 1

tset -34.849506 trajeto_2 2 0
tset -7.128908 trajeto_2 2 1

tset -34.854055 trajeto_2 3 0
tset -7.132954 trajeto_2 3 1

tset -34.853583 trajeto_2 4 0
tset -7.137638 trajeto_2 4 1

tset -34.852253 trajeto_2 5 0
tset -7.139767 trajeto_2 5 1

tset -34.851207 trajeto_2 6 0
tset -7.143316 trajeto_2 6 1

// Informacoes sobre a trajeto 3 ///////////////////
tset -34.851878 trajeto_3 0 0
tset -7.140817 trajeto_3 0 1

tset -34.850376 trajeto_3 1 0
tset -7.136899 trajeto_3 1 1

tset -34.854067 trajeto_3 2 0
tset -7.137623 trajeto_3 2 1

tset -34.860293 trajeto_3 3 0
tset -7.133720 trajeto_3 3 1

tset -34.859221 trajeto_3 4 0
tset -7.132698 trajeto_3 4 1

tset -34.860079 trajeto_3 5 0
tset -7.130058 trajeto_3 5 1

tset -34.872868 trajeto_3 6 0
tset -7.124650 trajeto_3 6 1

tset -34.869606 trajeto_3 7 0
tset -7.118006 trajeto_3 7 1

tset -34.874193 trajeto_3 8 0
tset -7.115251 trajeto_3 8 1

tset -34.877369 trajeto_3 9 0
tset -7.114782 trajeto_3 9 1

tset -34.877603 trajeto_3 10 0
tset -7.113771 trajeto_3 10 1

if($meu_id==1)
	script principal_TX
else
	script principal_RX
end 