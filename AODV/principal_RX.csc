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
				set custo 1	
				tset $custo vizinhos $j 1
				tset $x vizinhos $j 2
				tset 2 vizinhos $j 3
			end
		end			

	end

	// CODIGO PARA MOSTRAR MEUS VIZINHOS
	//cprint MEUS_VIZINHOS = 
	//for i 0 $n_nos
		//tget temp1 vizinhos $i 0
		//tget temp2 vizinhos $i 1
		//tget temp3 vizinhos $i 2
		//tget temp4 vizinhos $i 3
		//cprint | $temp1 | $temp2 | $temp3 | $temp4 |
	//end
	
	set etapa 3

end

loop

time x
int x $x

// Eventualidade
//if(($x>17)&&($meu_id==5))
	//battery set 0
//end

//atnd n_vizinhos_atual v_vizinhos_atual

//if($n_vizinhos_atual!=$ultimo_n_vizinhos)
	//mark 0
	//set etapa 1
	// Aqui eu tenho que descobrir quem saiu
//end

//if(($x>10)&&($meu_id==4))
	//battery set 0
	//set verifica ($verifica+60)
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
			vget fonte_ID recebido 2
			vget fonte_NS recebido 3
			vget dest_ID recebido 4
			vget dest_NS recebido 5
			vget numero_saltos recebido 6
			vget RREQ_ID recebido 7
			
			script roteamento
			
		end
		
		if($tipo_msg==2)
			//cprint RREP Recebida!
			
			vget origem recebido 1
			vget fonte_ID recebido 2
			vget fonte_NS recebido 3
			vget dest_ID recebido 4
			vget dest_NS recebido 5
			vget num_saltos_total recebido 6
			vget numero_saltos recebido 7
			vget RREQ_ID recebido 7
			
			// Aqui tenho que verificar se RREP e para mim
			// Se for, atualizo minha tabela de roteamento
			// Se nao for, atualizo minha tabela de roteamento e encaminho
			// Lembrar de consultar a tabela de requisicao para saber o caminho de volta
			
			script roteamento				
				
		end
		
		if($tipo_msg==3)
			// cprint MSG Hello Recebida!
			
			vget origem recebido 1
			vget fonte_ID recebido 2
			vget fonte_NS recebido 3
			vget dest_ID recebido 4
			vget dest_NS recebido 5
			vget destino_MSG recebido 6
			
			script roteamento
		end
		
		if($tipo_msg==4)
			// cprint RERR Recebida!
			
			vget origem recebido 1
			vget dest_ID recebido 2
			vget dest_NS recebido 3
			vget destino_MSG recebido 4
			
			script roteamento
		end
		
		if($tipo_msg==5)
			// cprint MSG Normal Recebida!
		
			//cprint MSG_Recebida = Msg normal
			// Aqui eu devo separar as variaveis e verificar se a msg eh para mim
			// Se nao for, devo encaminhar
		
			vget origem recebido 1
			vget destino recebido 2
			vget mensagem recebido 3
			vget tempo_envio recebido 4

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
								
				// INSERIR AQUI FUNCAO PARA VERIFICAR SE ROTA EH VALIDA ANTES DE ENVIAR
				
				// VERIFICACAO SE ROTA EH VALIDA
				set rota_valida 0
				
				// Obter proximo na RT
				for i 0 $n_nos
					set id ($i+1)
					int id $id
					
					if($id==$destino)
						tget encaminhar vizinhos $i 2
					end
				end
				
				// Obter vizinhos atuais
				atnd n_vizinhos_atuais v_vizinhos_atuais
				
				// Verificar se o proximo_salto esta na tabela de vizinhos atuais
				for i 0 $n_vizinhos_atuais
					vget vizinho_atual v_vizinhos_atuais $i
					if($vizinho_atual==$encaminhar)
						set rota_valida 1
					end
				end
			
			
				if($rota_valida==1)
					send $v $encaminhar
				else
					// A rota esta invalida
					// Incrementar NS do destino para proximo NS impar
					// Enviar RERR
					mark 0
					
					set destino_MSG $origem
					set dest_ID $destino
					
					// Incrementar NS do destino para proximo NS impar
					for i 0 $n_nos
						set id ($i+1)
						int id $id
						
						if($id==$dest_ID)
							tget dest_NS vizinhos $i 3
							// Incrementa NS proprio
							set dest_NS ($dest_NS+1)
							int dest_NS $dest_NS
							tset x vizinhos $i 1
							tset x vizinhos $i 2
							tset $dest_NS vizinhos $i 3				
						end
						
						if($id==$destino_MSG)
							tget encaminhar vizinhos $i 2
						end
						
					end
					
					cprint ENVIAR = $enviar
					cprint ORIGEM = $origem
					
					data enviar 4 $meu_id $dest_ID $dest_NS $destino_MSG
					send $enviar $encaminhar
			
				end
				
			end
					
		end

		
	end

end

delay 10 