// Mover para ponto inicial (partida)
if($trava_primeira_posicao==0)
	move -34.877603 -7.113771 0 100000
	
	time tempo_inicial
	set tempo_troca_ponto ($tempo_inicial+$tempo_pausa)
		
	set ponto 0
	set delay_tx 10
		
	set trava_primeira_posicao 1
end

loop

	// Aqui devo criar uma etapa obrigatoria para verificar se os vizinhos ainda estao online
	// Se sim, nao faz nada
	// Senao, incrementa NS do vizinho off para o proximo impar, atualiza RT e envia att parcial
	
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

time tempo

	if($x>=$verifica)
		
		cprint Atualizacao periodica completa iniciada...
		
		set etapa 1
		set verifica ($verifica+300)
	end

// Obtendo latitude e longitude proprias
getpos2 long lat

	// Tempo de espera antes de partir para proximo ponto
	if($ponto==0)
		set delay_tx 10
		if($tempo>=$tempo_troca_ponto)
			cprint Aguardou $tempo_pausa segundos e partiu...
			set ponto 1
			set delay_tx 1000
			set trajeto $prox_trajeto
		end
	else
		
		//cprint TRAJETO = $trajeto
		//cprint PONTO = $ponto
	
		if($trajeto==1)
		
			set ponto_tabela ($ponto-1)
				
			tget x_rota rota_1 $ponto_tabela 0
			tget y_rota rota_1 $ponto_tabela 1
			
			move $x_rota $y_rota 0 $velocidade
			if(($long==$x_rota)&&($lat==$y_rota))
			
				if($ponto<5)
					inc ponto
				else
					if($ponto==5)
						cprint A rota 1 foi completada!
						
						time tempo_chegada
						set tempo_troca_ponto ($tempo_chegada+$tempo_pausa)
						
						set prox_trajeto 2
						set ponto 0
					end
				end
			
			end
			
		end
		
		if($trajeto==2)
		
			// O ponto inicial eh o busto, mas o sensor ja esta nele
		
			set ponto_tabela ($ponto-1)
		
			tget x_rota rota_2 $ponto_tabela 0
			tget y_rota rota_2 $ponto_tabela 1
			
			move $x_rota $y_rota 0 $velocidade
			
			if(($long==$x_rota)&&($lat==$y_rota))
			
				if($ponto<7)
					inc ponto
				else
					if($ponto==7)
						cprint A rota 2 foi completada!
						
						time tempo_chegada
						set tempo_troca_ponto ($tempo_chegada+$tempo_pausa)
						
						set prox_trajeto 3
						set ponto 0
					end
				end
			
			end
		
		end
		
		if($trajeto==3)
		
		// O ponto inicial eh a UFPB, mas o sensor ja esta nele
		
			set ponto_tabela ($ponto-1)
		
			tget x_rota rota_3 $ponto_tabela 0
			tget y_rota rota_3 $ponto_tabela 1
			
			move $x_rota $y_rota 0 $velocidade
			
			if(($long==$x_rota)&&($lat==$y_rota))
			
				if($ponto<11)
					inc ponto
				else
					if($ponto==11)
						cprint A rota 3 foi completada!
						
						cprint REINICIANDO TODA A TRAJETORIA...
						
						time tempo_chegada
						set tempo_troca_ponto ($tempo_chegada+$tempo_pausa)
						
						set prox_trajeto 1
						set ponto 0
					end
				end
			
			end
		
		end
	
	end 


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
	
	set origem 0
	set etapa 3
	
	// O TX deve iniciar o compartilhamento de RT completa
	
end

// ETAPA PARA OBTER MEUS VIZINHOS (MODO RX) /////////////////////////////////////////////
if($etapa==2)

	wait 100
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
			cprint Mensagem normal recebida, loop infinito detectado!
		end
	end
	
end

// ETAPA PARA ENVIAR MEUS VIZINHOS (MODO TX) ////////////////////////////////////////
if($etapa==3)
// Nesta etapa a tabela de roteamento sera serializada para envio

	// Leitura da tabela de roteamento e criacao de variaveis
	// serializadas com os dados da tabela
	for i 0 $n_nos			
	
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

// ENVIO DE UMA MENSAGEM NORMAL /////////////////////////////////////////////////////
if($etapa==4)

	mark 1

	set origem $meu_id
	set destino 22
	set msg asdf
	set tipo_msg 2
	
	cprint ###############################################
	
	inc qtd_msgs_enviadas
	int qtd_msgs_enviadas $qtd_msgs_enviadas
	cprint ### QTD_MSGS_TX = $qtd_msgs_enviadas ###
	
	time tempo_envio
			
	data enviar $tipo_msg $origem $destino $msg $tempo_envio
	
	//time asdf
	//cprint TEMPO_ENVIO = $asdf	

	for i 0 $n_nos
		tget temp1 vizinhos $i 0
		tget temp3 vizinhos $i 2
		if($temp1==$destino)
			set destino_envia $temp3
		end
	end
	
	//cprint DESTINO_ENVIA = $destino_envia
	
	// Aqui tenho que verificar se o destino_envia esta online antes de enviar
	// Se estiver off, devo atualizar minha RT
	
	// Obter vizinhos
	atnd n_vizinhos_atual v_vizinhos_atual
	
	set perda_enlace 1
	
	for j 0 $n_vizinhos_atual
		vget viz v_vizinhos_atual $j
		if($viz==$destino_envia)
			//cprint ID = $id_RT ainda esta online!
			set perda_enlace 0
		end					
	end
	
	if($perda_enlace==1)
		// O enlace foi perdido, entao devo atualizar minha RT
		
		set indice_auxiliar ($destino-1)
		tset x vizinhos $indice_auxiliar 1
		tset x vizinhos $indice_auxiliar 2	
		cprint Enviando mensagem normal para $destino_envia 
		cprint O caminho ate o no $destino esta invalido!
		
	else
		if($destino_envia!=x)
			cprint Enviando mensagem normal para $destino_envia 
			
			send $enviar $destino_envia
		else
			cprint Nao foi possivel enviar, pois o proximo no esta offline!
		end
	end	
	
	set perda_enlace 0
	
	set etapa 2
end

	time fdsa
	
	if($fdsa>=$tempo_tx)
		set etapa 4
		set tempo_tx ($tempo_tx+30)
	end

delay $delay_tx 