if($tipo_msg==1)

	mark 0

	// Primeiro devo verificar se sou o destino ou o conheco
	// Se for ou conhecer, envio RREP de volta
	// Se nao for, salvo os dados no cache e encaminho para todos menos origem

	// Aqui devo atualizar adicionar a rota obtida ao meu cache de rotas
	// em seguida, devo encaminhar a mensagem com a nova rota via broadcast
	// So devo atualizar minha RT ao receber a RREP com a melhor rota	
	
	
	
	// Apenas o destino podera salvar no cache as rotas das RREQs
	//if($destino==$meu_id)
		
		//cprint CACHE = 
		//for i 0 $n_nos
			//tget temp1 cache $i 0
			//tget temp2 cache $i 1
			//cprint $temp1 | $temp2
		//end
	//end
	
	// Salvar a ultima RREQ processada
	if($ultima_rreq_recebida<$rreq_id)
		
		set ultima_rreq_recebida $rreq_id
	
		if($destino==$meu_id)
			cprint RREQ recebida pelo destino!
			
			// Acumula endereco na rota
			sadd $meu_id rota
			
			// Aqui enviar RREP para no fonte
			set rota_volta $rota
			
			cprint Enviando RREP para no fonte...
			
			// Retirar o proximo da rota_tempo e enviar para ele	
			spop destino_enviar rota_volta
			
			data enviar 2 $meu_id $rota_volta $fonte $destino $rota
			
				// Obter a potencia de TX
					for i 0 $n_nos
						set id ($i+1)
						int id $id
						
						if($id==$destino_enviar)
							tget pot vizinhos $i 2
						end
						
					end
					
					if($pot!=x)
						if($pot<=100)
							atpl $pot	
						else
							atpl 100
						end
					end
			
			send $enviar $destino_enviar
			
			atpl 100
			
		else
			// NAO SOU O DESTINO
			
			// Acumula endereco na rota
			sadd $meu_id rota
		
			data enviar $tipo_msg $meu_id $rreq_id $fonte $destino $rota
			
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
			
			atpl 100
			
		end
	
	end

end 
	
if($tipo_msg==2)
		
		// Ao receber a melhor rota, devo verificar se sou o destino
		// Se for, devo salvar info do destino com a melhor rota e enviar mensagem normal
		// Se nao for, devo salvar info da melhor rota e encaminhar RREP para proximo da rota_temp
		
		if($fonte==$meu_id)
			cprint RREP recebida pela fonte!
			
			// Zerando a rota invertida
			set rota_invertida \
			
			// Atualizar RT com info da rota recebida
			
			// Sera necessario inverter a rota antes de guardar

			// CODIGO PARA DESCOBRIR O NUMERO DE NOS DA ROTA (da string)
			length tamanho_vetor_rota_rrep $rota_rrep
			
			// A partir da expressao de uma PA eh possivel descobrir o numero de nos na string
			set qtd_nos_rota 0
			set qtd_nos_rota ((($tamanho_vetor_rota_rrep-1)/2)+1)
			int qtd_nos_rota $qtd_nos_rota
			
			//vec rota_invertida $qtd_nos_rota
			
			for i $qtd_nos_rota 0 -1
				spop temp rota_rrep
				
				if(($temp!=$meu_id)&&($temp!=$vazio))
					sadd $temp rota_invertida
				end
			end
			
			// Descarta o caractere vazio inicial
			//spop descarta_primeiro rota_invertida			
			
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$destino)
					tset $rota_invertida vizinhos $i 1
				end
				
				//tget temp vizinhos $i 0
				//tget temp2 vizinhos $i 1
				
				//cprint | $temp | $temp2 |
				
			end
			
			// Comentei isto daqui para fazer mais sentido... 
			//set etapa 2
		else
		
			// ENCAMINHAR
			// Retirar o proximo da rota_tempo e enviar para ele	
			spop destino_enviar rota_volta
			
			data enviar $tipo_msg $meu_id $rota_volta $fonte $destino $rota_rrep
			
				// Obter a potencia de TX
					for i 0 $n_nos
						set id ($i+1)
						int id $id
						
						if($id==$destino_enviar)
							tget pot vizinhos $i 2
						end
						
					end
					
					if($pot!=x)
						if($pot<=100)
							atpl $pot					
						else
							atpl 100
						end
					end
			
			send $enviar $destino_enviar
			
			atpl 100
			
		end
		
		
		
	
end
		
if($tipo_msg==3)
	// cprint MSG RERR Recebida!
	mark 0
	
	// Ao receber uma RERR remover da RT a rota
	for i 0 $n_nos
		set id ($i+1)
		int id $id
		
		if($id==$destino)
			tset x vizinhos $i 1
		end
		
	end
	
	if($origem==$meu_id)
		cprint RERR recebido e sou a fonte!
		set etapa 2
	else
		cprint RERR recebido e nao sou a fonte!
		
		spop destino_enviar rota_volta
					
		// Enviar uma RERR de volta para apagar rota
					
		data enviar 3 $origem $destino $rota_volta

			// Obter a potencia de TX
			for i 0 $n_nos
				set id ($i+1)
				int id $id
				
				if($id==$destino_enviar)
					tget pot vizinhos $i 2
				end
				
			end
			
			if($pot!=x)
				if($pot<=100)
					atpl $pot	
				else
					atpl 100
				end
			end
		
		send $enviar $destino_enviar
		
		atpl 100
		
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