// O RX nao tem msg de HELLO, entao nao tem verificacao periodica aqui

// ETAPA PARA OBTER MEUS VIZINHOS ///////////////////////////////////////////////////////
if($etapa==1) 

	// Obter vizinhos
	atnd n_vizinhos v_vizinhos

	// Preencher a tabela de roteamento com os vizinhos obtidos
	for i 0 $n_vizinhos
		vget x v_vizinhos $i

		for j 0 $n_nos
		tget temp vizinhos $j 0
			if($x==$temp)
				tset $x vizinhos $j 1
			end
		end			

	end

	// CODIGO PARA MOSTRAR MEUS VIZINHOS
	//cprint MEUS_VIZINHOS = 
	//for i 0 $n_nos
		//tget temp1 vizinhos $i 0
		//tget temp2 vizinhos $i 1
		//cprint | $temp1 | $temp2 |
	//end
	
	set etapa 3

end

loop

time x
int x $x

// Eventualidades
//if(($meu_id==9)&&($x>12))
	//battery set 0
//end

//if(($meu_id==3)&&($x>25))
	//battery set 0
//end

// ETAPA PARA OBTER MEUS VIZINHOS (MODO RX) /////////////////////////////////////////////
if($etapa==3)
// Mensagem tipo 1 = RREQ
// Mensagem tipo 2 = RREP
// Mensagem tipo 3 = RERR
// Mensagem tipo 4 = HELLO
// Mensagem tipo 5 = Mensagem normal

	// Aguarda receber algo 
	wait 10000
	// Salva o que foi lido na variavel V (mesmo que nao seja nada)
	read v 	
	
	// Verifica se recebeu algo no WAIT
	if($v!=$vazio) 

		// Separa os dados serializados recebidos em um vetor
		vdata recebido $v
		
		// Identifica primeiro o tipo de mensagem recebida
		vget tipo_msg recebido 0
		
		if($tipo_msg==1)
			//cprint RREQ Recebida!
			
			vget origem recebido 1
			vget rreq_id recebido 2
			vget fonte recebido 3
			vget destino recebido 4
			vget rota recebido 5
			
			script roteamento
			
		end
		
		if($tipo_msg==2)
			//cprint RREP Recebida!
			
			vget origem recebido 1
			vget rota_volta recebido 2
			vget fonte recebido 3
			vget destino recebido 4
			vget rota_rrep recebido 5
			
			// Aqui tenho que verificar se RREP e para mim
			// Se for, atualizo minha tabela de roteamento
			// Se nao for, atualizo minha tabela de roteamento e encaminho
			// Lembrar de consultar a tabela de requisicao para saber o caminho de volta
			
			script roteamento				
				
		end
		
		if($tipo_msg==3)
			// cprint RERR Recebida!
			
			vget origem recebido 1
			vget destino recebido 2
			vget rota_volta recebido 3
			
			script roteamento
		end
		
		if($tipo_msg==4)
			// cprint MSG Normal Recebida!
		
			//cprint MSG_Recebida = Msg normal
			// Aqui eu devo separar as variaveis e verificar se a msg eh para mim
			// Se nao for, devo encaminhar
		
			vget origem recebido 1
			vget rota_volta recebido 2
			vget destino recebido 3
			vget rota recebido 4
			vget mensagem recebido 5
			vget tempo_envio recebido 6

			if($destino==$meu_id)
				led 1 3
				cprint ORIGEM = $origem
				cprint DESTINO = $destino
				cprint MSG = $mensagem
				
				if($trava_tempo_primeira_msg!=1)
					time tempo_primeira_msg
					set trava_tempo_primeira_msg 1
				end
				
				inc qtd_msgs_recebidas
				int qtd_msgs_recebidas $qtd_msgs_recebidas
				
				cprint ### QTD_MSGS_RX = $qtd_msgs_recebidas ###	

				cprint ### TEMPO_PRIMEIRA_MSG = $tempo_primeira_msg ###

				time tempo_recebimento
				
				// Calculo da latencia
				set delay_msg ($tempo_recebimento-$tempo_envio)
				set soma_delay ($soma_delay+$delay_msg)
				set delay_medio ($soma_delay/$qtd_msgs_recebidas)
				
				// Calculo do jitter
				set jitter_atual ($delay_msg-$delay_anterior)
				set soma_jitter ($soma_jitter+$jitter_atual)
				set jitter_medio ($soma_jitter/$qtd_msgs_recebidas)
				set delay_anterior $delay_msg
				
				cprint ### TEMPO_RECEBIMENTO = $tempo_recebimento ###
				cprint ### DELAY_MEDIO = $delay_medio ###
				cprint ### JITTER_MEDIO = $jitter_medio ###
				
			else
				mark 1
				
				// Acumular meu endereco na rota de volta
				sadd $meu_id rota_volta
				
				// Antes de tudo, devo verificar se a rota eh valida
				// Se for, encaminho a mensagem
				// Se nao for, devo enviar uma RERR de volta para a fonte
				
				// VERIFICACAO SE ROTA EH VALIDA
				set rota_valida 0
				
				// Retirar o proximo da rota_temp e enviar para ele	
				spop destino_enviar rota
				
				// Obter vizinhos atuais
				atnd n_vizinhos_atuais v_vizinhos_atuais
				
				// Verificar se o proximo_salto esta na tabela de vizinhos atuais
				for i 0 $n_vizinhos_atuais
					vget vizinho_atual v_vizinhos_atuais $i
					if($vizinho_atual==$destino_enviar)
						set rota_valida 1
					end
				end
				
				if($rota_valida==1)
				
					data enviar $tipo_msg $origem $rota_volta $destino $rota mensagem_qualquer $tempo_envio
					send $enviar $destino_enviar
				else
					
					mark 0
					cprint ROTA INVALIDA!
					
					//spop descarta_primeiro rota_volta
					
					spop destino_enviar rota_volta
					
					// Enviar uma RERR de volta para apagar rota
					set tipo_msg 3
					
					data enviar $tipo_msg $origem $destino $rota_volta 
					send $enviar $destino_enviar
					
					cprint $enviar
					
				end
				
			end
	
		end

		
	end

end

delay 10 