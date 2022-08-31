// Mover para ponto inicial (partida)
if($trava_primeira_posicao==0)
	move -34.877603 -7.113771 0 100000
	
	time tempo_inicial
	set tempo_troca_ponto ($tempo_inicial+$tempo_pausa)
		
	set ponto 0
	set delay_tx 10
		
	set trava_primeira_posicao 1
end

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
				tset 100 vizinhos $j 2
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
	
	set etapa 2
	
end

loop

time x
int x $x

time tempo

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


// COLOCAR AQUI CODIGO PARA DECIDIR MELHOR ROTA (tem no principal_RX)

if($etapa==2)
	// O primeiro passo e verificar se o no conhece a rota para um determinado destino
	// Se conhece, apenas envia identificando o tipo correto de msg
	// Senao, envia uma mensagem RREQ para descobrir a rota
	
	
	set dest 22
	
	//if($meu_id==3)
		//set dest 8
	//end
	
	// Verifico se conheco a rota ate o destino
	// Se sim, envio a mensagem como tipo 3
	// Senao, envio RREQ
	
	//cprint RT =
	//for i 0 $n_nos
		//tget temp1 vizinhos $i 0
		//tget temp2 vizinhos $i 1
		//cprint $temp1 | $temp2
	//end
	
	//cprint CACHE = 
	//for i 0 99
		//tget temp1 cache $i 0
		//tget temp2 cache $i 1
		//cprint $temp1 | $temp2
	//end
	
	set conheco_destino 0
	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		// Seleciono a linha do destino
		if($id==$dest)
			tget temp vizinhos $i 1
			
			// Verifico se nao eh um valor desconhecido
			if($temp!=x)
				set conheco_destino 1
				set i $n_nos
			end
		end
		
	end
	
	if($conheco_destino==1)
	
	cprint ###############################################
	
	inc qtd_msgs_enviadas
	int qtd_msgs_enviadas $qtd_msgs_enviadas
	cprint ### QTD_MSGS_TX = $qtd_msgs_enviadas ###
	
		cprint Conheco o destino!
	
		set tipo_msg 4
		set rota $temp
		set rota_volta $meu_id

		// ENCAMINHAR
		// Retirar o proximo da rota_temp e enviar para ele	
		spop destino_enviar rota
		
		// VERIFICACAO SE ROTA EH VALIDA
		set rota_valida 0
		
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

			time tempo_envio
		
			data enviar $tipo_msg $meu_id $rota_volta $dest $rota mensagem_qualquer $tempo_envio 
			//delay 2000
			mark 1
			
			send $enviar $destino_enviar
			//delay 1000
			
			set etapa 3
			//stop
		else
			mark 0
			cprint ROTA INVALIDA!
		
			set tipo_msg 3
			
			set origem $meu_id
			set destino $dest
			
			script roteamento 
		
		end
	
	else
	// Se nao conheco o destino, devo criar uma RREQ
		
		cprint Nao conheco o destino, entao uma RREQ sera enviada
		
		// Crio uma mensagem RREQ
		set tipo_msg 1
		set origem $meu_id
		inc rreq_id
		int rreq_id $rreq_id
		set fonte $meu_id
		set destino $dest
		set rota $meu_id
		
		data enviar $tipo_msg $origem $rreq_id $fonte $destino $rota
		
		set maior 0
				for i 0 $n_nos
					tget pot vizinhos $i 2
					
					if($pot!=x)
						if($pot>$maior)
							set maior $pot
						end
					end
					
				end
				//cprint MAIOR = $maior
				if($maior<=100)
					atpl $maior
				end
		
		send $enviar * $origem
		
		set etapa 3
	
	end
end

// ETAPA PARA OBTER MEUS VIZINHOS (MODO RX) /////////////////////////////////////////////
if($etapa==3)
// Mensagem tipo 1 = RREQ
// Mensagem tipo 2 = RREP
// Mensagem tipo 3 = RERR
// Mensagem tipo 4 = Mensagem normal

	// Aguarda receber algo 
	wait 100
	// Salva o que foi lido na variavel V (mesmo que nao seja nada)
	read v 	
	
	// Verifica se recebeu algo no WAIT
	if($v!=$vazio) 

		// Separa os dados serializados recebidos em um vetor
		vdata recebido $v
		
			// Verifica o RSSI e faz o ajuste de potencia de TX
			// Calcula o RSSI da ultima MSG recebida
			//cprint -------------------
			//cprint DIST (m) = 
			drssi d
			
			// Parametros de simulacao
			set freq 915000000
			set velocidade_ajuste 300000000
			set comprimento_onda ($velocidade_ajuste/$freq)
			set d0 1
			set n 3.3
			set pi 3.14 
			
			set temp ((4*$pi*$d0)/$comprimento_onda)
			
			math log10 lg $temp
			
			set pl_d0 (20*$lg)
			
			set temp ($d/$d0)
			math log10 lg $temp
			
			set rssi ($pl_d0+(10*$n*$lg))
			set rssi -($rssi)
			//int rssi $rssi
			
			//cprint RSSI = $rssi dBm
			
			// Agora vou aplicar esse valor na EQ que vou obter depois
			
			math pow temp2 10 -7
			math pow temp $rssi 5
			set termo_1 (-1.161169468381691*$temp2*$temp)
			
			math pow temp2 10 -5
			math pow temp $rssi 4
			set termo_2 (-4.870470506506291*$temp2*$temp)
			
			math pow temp $rssi 3
			set termo_3 (-0.008114743288230*$temp)
			
			math pow temp $rssi 2
			set termo_4 (-0.660852476932444*$temp)
			
			set termo_5 (-25.953469491107786*$rssi)
			
			math pow temp2 10 2
			set termo_6 (-3.829454402717133*$temp2)
			
			set pot_calc ($termo_1+$termo_2+$termo_3+$termo_4+$termo_5+$termo_6)
			set pot_calc ($pot_calc+2)
			//int pot_calc $pot_calc
			
			vget destino_pot_calc recebido 1
			
			// Altera na RT o valor de potencia para destino calculado
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$destino_pot_calc)
					if($destino_pot_calc!=$meu_id)
						tset $pot_calc vizinhos $i 2
					end
				end
				
				//if($meu_id==2)
				//tget temp1 vizinhos $i 0
				//tget temp2 vizinhos $i 1
				//tget temp3 vizinhos $i 2
				//cprint | $temp1 | $temp2 | $temp3
				//end
				
			end
			
			//cprint -------------------
		
		// Identifica primeiro o tipo de mensagem recebida
		vget tipo_msg recebido 0
		
		if($tipo_msg==1)
			//cprint RREQ Recebida!
			
			// Este no ignora todas as RREQs recebidas, pois eh um novo fonte
			
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
			//vget rota_volta recebido 3
		
			//cprint RECEBIDO = $v
		
			//cprint ROTA_ERRO = $rota_erro
			
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

			if($destino==$meu_id)
				led 1 3
				cprint ORIGEM = $origem
				cprint DESTINO = $destino
				cprint MSG = $mensagem
			else
				mark 1
				
				// Acumular meu endereco na rota de volta
				sadd $meu_id rota_volta
				
				// Retirar o proximo da rota_tempo e enviar para ele	
				spop destino_enviar rota
				
				data enviar $tipo_msg $origem $rota_volta $destino $rota mensagem_qualquer
				
				send $enviar $destino_enviar
				
				// CODIGO PARA VERIFICAR SE A ROTA EH VALIDA
					
		end

	end
	
end
		
	time fdsa
	
	if($fdsa>=$tempo_tx)
		set etapa 2
		set tempo_tx ($tempo_tx+30)
	end

//rmove 20
delay $delay_tx 