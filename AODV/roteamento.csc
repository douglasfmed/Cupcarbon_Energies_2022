if($tipo_msg==1)

	mark 0

	set processar_RREQ 0
	
	// Obtenho a ultima RREQ processada daquela fonte para comparacao
	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		if($id==$fonte_ID)
			tget ultima_RREQ RREQ_ID_TAB $i 0
			set i $n_nos
		end
	end
	
	// Agora verifico se esta requisicao ja foi processada antes
	if($RREQ_ID > $ultima_RREQ)
		// Se sim, salvo esta RREQ como sendo a ultima processada agora
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			if($id==$fonte_ID)
				tset $RREQ_ID RREQ_ID_TAB $i 0
			end
		end
		
		set processar_RREQ 1
		
	end

	
	if($processar_RREQ==1)
	// Se for para processar RREQ entra aqui

		// Atualizo RT com info da fonte
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			
			if($id==$fonte_ID)
				tset $numero_saltos vizinhos $i 1
				tset $origem vizinhos $i 2
				tset $fonte_NS vizinhos $i 3
			end
			
			if($id==$dest_ID)
				tget dest_NS_RT vizinhos $i 3
			end
			
		end
	

		if($dest_ID==$meu_id)
		// Se a RREQ eh para mim, envio RREP de volta
		
			// Devo atualizar meu NS proprio
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$dest_ID)
					tget dest_NS_RT vizinhos $i 3
					set dest_NS_RT ($dest_NS_RT+2)
					tset $dest_NS_RT vizinhos $i 3
				end
			end
		
			cprint RREQ Recebida pelo destino!
			
			set tipo_msg 2
			set num_saltos_total ($numero_saltos+1)
			int num_saltos_total $num_saltos_total
			dec numero_saltos
			int numero_saltos $numero_saltos
			
			data enviar $tipo_msg $meu_id $fonte_ID $fonte_NS $dest_ID $dest_NS_RT $num_saltos_total $numero_saltos $RREQ_ID
			
			led 1 4
			//delay 1000
			mark 0
			
			send $enviar $origem
		else
		// Nao conheco o destino, entao encaminho
		
				inc numero_saltos
				int numero_saltos $numero_saltos
				
				data enviar $tipo_msg $meu_id $fonte_ID $fonte_NS $dest_ID $dest_NS $numero_saltos $RREQ_ID
				send $enviar * $origem
			
		end
	
	end


end 
	
if($tipo_msg==2)
		
		// Atualizar so se a RREP tiver um NS maior do que o da minha RT
		set linha ($dest_ID-1)
		tget NS_RT vizinhos $linha 3
		
		if($dest_NS>$NS_RT)
		// ESTA VERIFICACAO ESTA DANDO PROBLEMA
	
			// Atualizo minha RT com as informacoes do destino	
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$dest_ID)
					tset $num_saltos_total vizinhos $i 1
					tset $origem vizinhos $i 2
					tset $dest_NS vizinhos $i 3
				end
				
				if($id==$dest_ID)
					tget novo_dest_NS vizinhos $i 3
					set $novo_dest_NS $dest_NS 
				end
				
				if($id==$fonte_ID)
					tget encaminhar vizinhos $i 2
				end
				
			end	
	
			if($fonte_ID==$meu_id)
				cprint RREP recebida e sou o destino!
				//set etapa 2
				//cprint RREQ_ID_TAB = 
				//for i 0 $n_nos
					//tget temp RREQ_ID_TAB $i 0
					//cprint $temp
				//end
			else
				dec numero_saltos
				int numero_saltos $numero_saltos 
				
				data enviar $tipo_msg $meu_id $fonte_ID $fonte_NS $dest_ID $dest_NS $num_saltos_total $numero_saltos $RREQ_ID
				send $enviar $encaminhar
			end
		
		end
	
end
		
if($tipo_msg==3)
	//cprint MSG de HELLO Recebida!
	
	if($dest_ID==$meu_id)
	// Sou o destino
	
		// Atualizo RT com info da fonte
		for i 0 $n_nos
			set id ($i+1)
			int id $id
			
			if($id==$fonte_ID)
				tset $fonte_NS vizinhos $i 3				
				tget encaminhar vizinhos $i 2
			end
			
			if($id==$dest_ID)
				tget dest_NS vizinhos $i 3
				// Incrementa NS proprio
				set dest_NS ($dest_NS+2)
				int dest_NS $dest_NS
				tset $dest_NS vizinhos $i 3				
			end
			
		end		
		
		// Incremento meu NS
		
		// Envio HELLO de volta
		// Devo inverter o destino_MSG para fonte
		
		set destino_volta $origem
		
		set tipo_msg 3
		set destino_MSG $fonte_ID
		
		data enviar $tipo_msg $meu_id $fonte_ID $fonte_NS $dest_ID $dest_NS $destino_MSG
		send $enviar $destino_volta
		
	else
		if($fonte_ID==$meu_id)
		// Sou a fonte
		
			cprint HELLO respondida!
		
			// Atualizo RT com info do destino			
			for i 0 $n_nos
				set id ($i+1)
				int id $id
			
				if($id==$dest_ID)
					tset $dest_NS vizinhos $i 3	
				end
			end
			
			//set etapa 2
		
		else
		// Nenhum dos dois (nem fonte nem destino)
		
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$destino_MSG)
					tget encaminhar vizinhos $i 2
				end
				
			end
			
			data enviar 3 $meu_id $fonte_ID $fonte_NS $dest_ID $dest_NS $destino_MSG
			
			// VERIFICACAO SE ROTA EH VALIDA
			set rota_valida 0
			
			// Obter proximo na RT
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$destino_MSG)
					tget proximo_RT vizinhos $i 2
				end
			end
			
			// Obter vizinhos atuais
			atnd n_vizinhos_atuais v_vizinhos_atuais
			
			// Verificar se o proximo_salto esta na tabela de vizinhos atuais
			for i 0 $n_vizinhos_atuais
				vget x v_vizinhos_atuais $i
				if($x==$proximo_RT)
					set rota_valida 1
				end
			end
		
			if($rota_valida==1)
				send $enviar $encaminhar
			else
				// A rota esta invalida
				// Incrementar NS do destino para proximo NS impar
				// Enviar RERR
				mark 0
				
				set destino_MSG $fonte_ID
				
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
				
				data enviar 4 $meu_id $dest_ID $dest_NS $destino_MSG
				send $enviar $origem
		
			end				
			
			
		end
	end
	
end

if($tipo_msg==4)
	// cprint MSG RERR Recebida!
	mark 0
	
	// Atualizar RT com info do destino
	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		if($id==$dest_ID)
			tset x vizinhos $i 1
			tset x vizinhos $i 2
			tset $dest_NS vizinhos $i 3	
		end
		
		if($id==$destino_MSG)
			tget encaminhar vizinhos $i 2
		end
		
	end
	
	// Verificar se sou o destino_MSG
	// Se nao for, encaminhar para proximo
	if($destino_MSG==$meu_id)
		cprint RERR recebido pela fonte!
		set libera_TX 0
		set etapa 2
	else
		data enviar 4 $meu_id $dest_ID $dest_NS $destino_MSG
		send $enviar $encaminhar
	end
	
end



// Redirecionamento final de volta de acordo com ID do no sensor
if($meu_id==1)
	// Na volta o TX vai tentar enviar a MSG de novo, pois agora conhece a rota
	script principal_TX
else
	set etapa 3
	script principal_RX
end 