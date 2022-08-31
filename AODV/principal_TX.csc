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
	
	set etapa 2
	
end

loop

time x
int x $x

time tempo

// Obtendo latitude e longitude proprias
getpos2 long lat

// Manutencao de rotas periodica (T=20s) (HELLO)
if($x>=$verifica)

	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		if($id==$meu_id)
			tget temp1 vizinhos $i 3
			// Incrementa NS proprio
			set temp1 ($temp1+2)
			int temp1 $temp1
			tset $temp1 vizinhos $i 3
		end
		
		if($id==$dest)
			tget proximo_enviar vizinhos $i 2
			tget temp2 vizinhos $i 3
		end
		
	end

	set tipo_msg 3
	set origem $meu_id
	set fonte_ID $meu_id
	set fonte_NS $temp1
	set dest_ID $dest
	set dest_NS $temp2
	set destino_MSG $dest
	
	data enviar $tipo_msg $origem $fonte_ID $fonte_NS $dest_ID $dest_NS $destino_MSG
	
	// Rotina para verificar se rota ainda eh valida, antes de enviar msg de HELLO
	
	// VERIFICACAO SE ROTA EH VALIDA
		set rota_valida 0
		
		// Obter vizinhos atuais
		atnd n_vizinhos_atuais v_vizinhos_atuais
		
		// Verificar se o proximo_salto esta na tabela de vizinhos atuais
		for i 0 $n_vizinhos_atuais
			vget vizinho_atual v_vizinhos_atuais $i
			if($vizinho_atual==$proximo_enviar)
				set rota_valida 1
			end
		end
		
		if($rota_valida==1)
			send $enviar $proximo_enviar
		else
			
			cprint Nao foi possivel enviar mensagem de HELLO, a rota nao eh mais valida!
		
			// A rota esta invalida
			// Incrementar NS do destino para proximo NS impar
			// Enviar RERR
			mark 0
			
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
				
			end
			
			set etapa 2
			
		end
	
	
	set verifica ($verifica+90)
	
end

//if($x==$periodo_TX)
	//set etapa 2
	//set periodo_TX ($periodo_TX+10)
//end

// Tempo de espera antes de partir para proximo ponto
if($ponto==0)
	set delay_tx 10
	if($tempo>=$tempo_troca_ponto)
		cprint Aguardou 20 segundos e partiu...
		set ponto 1
		set delay_tx 1000
		set trajeto $prox_trajeto
	end
else

	if($trajeto==1)
	
		set ponto_tabela ($ponto-1)
			
		tget x_trajeto trajeto_1 $ponto_tabela 0
		tget y_trajeto trajeto_1 $ponto_tabela 1
		
		move $x_trajeto $y_trajeto 0 $velocidade
		
		if(($long==$x_trajeto)&&($lat==$y_trajeto))
		
			if($ponto<5)
				inc ponto
			else
				if($ponto==5)
					cprint A trajeto 1 foi completada!
					
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
			
		tget x_trajeto trajeto_2 $ponto_tabela 0
		tget y_trajeto trajeto_2 $ponto_tabela 1
		
		move $x_trajeto $y_trajeto 0 $velocidade
		
		if(($long==$x_trajeto)&&($lat==$y_trajeto))
		
			if($ponto<7)
				inc ponto
			else
				if($ponto==7)
					cprint A trajeto 2 foi completada!
					
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
			
		tget x_trajeto trajeto_3 $ponto_tabela 0
		tget y_trajeto trajeto_3 $ponto_tabela 1
		
		move $x_trajeto $y_trajeto 0 $velocidade
		
		if(($long==$x_trajeto)&&($lat==$y_trajeto))
		
			if($ponto<11)
				inc ponto
			else
				if($ponto==11)
					cprint A trajeto 3 foi completada!
					
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
	
	set conheco_destino 0
	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		// Seleciono a linha do destino
		if($id==$dest)
			tget temp vizinhos $i 1
			tget enviar_final vizinhos $i 2
			
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
	
		set tipo_msg 5
				
		// INSERIR AQUI FUNCAO PARA VERIFICAR SE ROTA EH VALIDA ANTES DE ENVIAR
		
		// VERIFICACAO SE ROTA EH VALIDA
		set rota_valida 0
		
		// Obter proximo na RT
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			
			if($id==$dest)
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
		
			time tempo_envio
			
			data enviar $tipo_msg $meu_id $dest mensagem_qualquer $tempo_envio
		
			//delay 3000
			mark 1
			send $enviar $enviar_final
		
			set etapa 3
			//stop
		else
			
			cprint Rota invalida (TX)!
		
			// A rota esta invalida
			// Incrementar NS do destino para proximo NS impar
			// Enviar RERR
			mark 0
			
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
				
			end
			
			set tipo_msg 4		
			
			set origem $meu_id
			set dest_ID $dest
			set dest_NS $dest_NS
			set destino_MSG $meu_id
			
			script roteamento 
			
		end
	
	else
	// Se nao conheco o destino, devo criar uma RREQ
		
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			
			if($id==$meu_id)
			// Devo incrementar meu NS aqui
			
				tget temp1 vizinhos $i 3
			end
			
			if($id==$dest)
				tget temp2 vizinhos $i 3
			end
		end

		// Crio uma mensagem RREQ
		set tipo_msg 1
		set origem $meu_id
		set fonte_ID $meu_id
		set fonte_NS $temp1
		set dest_ID $dest
		set dest_NS $temp2
		set numero_saltos 1
		
		// Incremento o numero da RREQ do meu_id
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			
			if($id==$meu_id)
				tget RREQ_atual RREQ_ID_TAB $i 0
					inc RREQ_atual
					int RREQ_atual $RREQ_atual
				tset $RREQ_atual RREQ_ID_TAB $i 0
				tget RREQ_ID RREQ_ID_TAB $i 0
			end
			
		end
		
		data enviar $tipo_msg $origem $fonte_ID $fonte_NS $dest_ID $dest_NS $numero_saltos $RREQ_ID
		send $enviar 
		
		set etapa 3
	
	end
end

// ETAPA PARA OBTER MEUS VIZINHOS (MODO RX) /////////////////////////////////////////////
if($etapa==3)
// Mensagem tipo 1 = RREQ
// Mensagem tipo 2 = RREP
// Mensagem tipo 3 = RERR
// Mensagem tipo 4 = HELLO
// Mensagem tipo 5 = Mensagem normal

	// Aguarda receber algo 
	wait 100
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
			


			if($destino==$meu_id)
				led 1 3
				cprint ORIGEM = $origem
				cprint DESTINO = $destino
				cprint MSG = $mensagem
			else
				mark 1
				for i 0 $n_nos
					set id ($i+1)
					int id $id
					
					if($id==$destino)
						tget encaminhar vizinhos $i 2
					end
				end
				
				// INSERIR AQUI FUNCAO PARA VERIFICAR SE ROTA EH VALIDA ANTES DE ENVIAR
				
				send $v $encaminhar
			end
					
		end

		
	end


end

	time fdsa
	
	if($fdsa>=$tempo_tx)
		set etapa 2
		set tempo_tx ($tempo_tx+30)
	end

delay $delay_tx 