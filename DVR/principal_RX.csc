
loop

	// Obter vizinhos
	atnd n_vizinhos_atual v_vizinhos_atual
	
	if($n_vizinhos_atual!=$ultimo_n_vizinhos)
		// So vai entrar aqui quando houver alguma mudanca de topologia
		// Mas agora eh preciso descobrir quem ficou offline
		
		set perda_enlace 1
		
		// Cada vizinho da RT com custo=1 sera comparado com o vetor atual
		for i 0 $n_nos
		tget id_RT vizinhos $i 0
		tget custo_RT vizinhos $i 1
		
			if($custo_RT==1)
				// Se o vizinho da RT nao estiver na lista de atuais, ele ficou off
				// Nesse caso, deve ser enviada uma msg parcial de atualizacao
				// Lembrar de incrementar o NS para o proximo impar
				
				for j 0 $n_vizinhos_atual
					vget viz v_vizinhos_atual $j
					if($viz==$id_RT)
						//cprint ID = $id_RT ainda esta online!
						set perda_enlace 0
					end					
				end
				
				if($perda_enlace==1)
					//cprint O no $id_RT esta offline!
					
					tset x vizinhos $i 1
					tset x vizinhos $i 2
					
					//cprint RT atualizada!
					
					set ultimo_n_vizinhos $n_vizinhos_atual
				end
				
				set perda_enlace 1
				
			end			
		
		end
	
	end

time x
int x $x

// Eventualidades
//if(($meu_id==9)&&($x>12))
	//battery set 0
//end

// ETAPA PARA OBTER MEUS VIZINHOS ///////////////////////////////////////////////////
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
			end
		end			

	end

	// CODIGO PARA MOSTRAR MEUS VIZINHOS
	//cprint MEUS_VIZINHOS = 
	//for i 0 $n_nos
		//tget temp1 vizinhos $i 0
		//tget temp2 vizinhos $i 1
		//tget temp3 vizinhos $i 2
		//cprint | $temp1 | $temp2 | $temp3 |
	//end
	
	set etapa 2
end

// ETAPA PARA OBTER MEUS VIZINHOS (MODO RX) /////////////////////////////////////////////
if($etapa==2)

	wait 5000
	read v
			
	if($v!=$vazio)
		
		// Separa os dados serializados recebidos em um vetor
		vdata recebido $v
		
		// Identifica primeiro o tipo de mensagem recebida
		vget tipo_msg recebido 0
		
		if($tipo_msg==1)
			mark 0
			// RT completa ou atualizacao parcial recebido		
			script roteamento
		end
		
		if($tipo_msg==2)
			// Mensagem normal recebida
			mark 1
			
			vget origem recebido 1
			vget destino recebido 2
			vget msg recebido 3
			vget tempo_envio recebido 4
			
			if($destino==$meu_id)
				led 1 4
				cprint ORIGEM = $origem
				cprint DESTINO = $destino
				cprint MSG = $msg
				//print $v
				//led 1 2
				
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
				for i 0 $n_nos
					tget temp1 vizinhos $i 0
					tget temp3 vizinhos $i 2
					if($temp1==$destino)
						set destino_envia $temp3
					end
				end

				if($destino_envia!=x)
					//cprint Encaminhando mensagem normal para $destino_envia
					send $v $destino_envia
				else
					cprint Nao foi possivel enviar, pois o proximo no esta offline!
				end
				//led 1 2
			end
			
		end
	else
		set info_repetida 0
	end
	
end

// ETAPA PARA ENVIAR MEUS VIZINHOS (MODO TX) ////////////////////////////////////////
if($etapa==3)
// Nesta etapa a tabela de roteamento sera serializada para envio

	// Leitura da tabela de roteamento e criacao de variaveis
	// serializadas com os dados da tabela
	for i 0 $n_nos
	
		// INCREMENTO DE ATUALIZACAO
		// Sempre que for enviar algo, incrementar o proprio
		// numero de sequencia para o proximo numero par
	
		tget temp2 vizinhos $i 1
		tget temp3 vizinhos $i 2
		if($i==0)
			data custos $temp2
			data proximos_saltos $temp3
		else
			data custos $custos $temp2
			data proximos_saltos $proximos_saltos $temp3
		end
	end
	
	// Variavel final que sera enviada
	// (tabela de roteamento completa)
	data enviar 1 $meu_id $custos $proximos_saltos 
	// Envio dos dados (broadcast)
	
	atnd n_vizinhos_atual
	if($n_vizinhos_atual>=2)
		send $enviar * $origem
	else
		send $enviar
	end
	
	set etapa 2
	
end
	
delay 10 