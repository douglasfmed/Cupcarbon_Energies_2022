// Modificar aqui para verificar o tipo de MSG e depois retornar para principal TX ou RX

if($tipo_msg==1)

	mark 0

	// RECEBO A RT COMPLETA E SALVO EM VIZINHOS_RECEBIDOS >>>>>>>>>>>>>>>>>>>>>

		// Salva a origem da mensagem
		vget origem recebido 1
		
		// Daqui para baixo sao criadas algumas variaveis que serao
		// usadas nos limites dos FOR de separacao dos dados
		// A descricao destes limites esta exemplificada no arquivo que
		// detalha o metodo de serializacao criado
		set n $n_nos
		int n $n
		
		set 2n ($n*2)
		int 2n $2n
		
		set 3n ($n*3)
		int 3n $3n
		
		set n $n_nos
		int n $n

		set n_+_1 ($n+1)
		int n_+_1 $n_+_1
		
		set n_+_2 ($n+2)
		int n_+_2 $n_+_2

		set 2n_+_1 ($2n+1)
		int 2n_+_1 $2n_+_1
		
		set 2n_+_2 ($2n+2)
		int 2n_+_2 $2n_+_2
		
		// Separa os custos recebidos
		set j 0
		for i 2 $n_+_2
			vget temp recebido $i
			tset $temp vizinhos_recebidos $j 1
			inc j
		end

		// Separa os proximos saltos recebidos
		set j 0
		for i $n_+_2 $2n_+_2
			vget temp recebido $i
			tset $temp vizinhos_recebidos $j 2
			inc j
		end
		
		// CODIGO PARA MOSTRAR VIZINHOS RECEBIDOS
		//cprint VIZINHOS_RECEBIDOS = 
		//for i 0 $n_nos
			//tget temp1 vizinhos_recebidos $i 0
			//tget temp2 vizinhos_recebidos $i 1
			//tget temp3 vizinhos_recebidos $i 2
			//cprint | $temp1 | $temp2 | $temp3 |
		//end
		
	// Depois de separar tudo, tem que ir para etapa de comparacao >>>>>>>>>>>>>>>>
	
	// Verificar primeiro se houve atualizacao no NS do TX
	// Se sim, incremento meu NS tambem
	// Senao, atualizo minha RT e repasso tudo sem atualizar meu NS proprio
	
	set atualiza 0
	
		// As verificacoes serao feitas com as variaveis: CUSTO e CUSTO_RECEBIDO
        for i 0 $n_nos
            tget custo vizinhos $i 1
            tget custo_recebido vizinhos_recebidos $i 1
			
			// Verifica se a linha atual das tabelas nao se trata de informacoes do 
			// proprio no ou do no de origem. Tambem e verificado se a informacao 
			// recebida nao e um valor desconhecido (infinito = x)
			if(($custo!=0)&&($custo_recebido!=0)&&($custo_recebido!=x))

				// Verifica se a linha atual da tabela de roteamento e um valor desconhecido
				if($custo==x)
					// Se for, entao deve-se atualizar aquela linha com os dados recebidos
						set novo_custo ($custo_recebido+1)
						int novo_custo $novo_custo

						tset $novo_custo vizinhos $i 1 
						tset $origem vizinhos $i 2
						set atualiza 1
				// Senao, se a linha da tabela ja possui um valor, deve-se comparar o custo
				// recebido com o custo atual, se for menor, deve-se atualizar a tabela
				else
					set custo_compara ($custo_recebido+1)
					int custo_compara $custo_compara
					
						if($custo_compara<$custo)
							set novo_custo ($custo_recebido+1)
							int novo_custo $novo_custo

							tset $novo_custo vizinhos $i 1 
							tset $origem vizinhos $i 2
							set atualiza 1
						end
				end
				   
            end

        end
		
		if($atualiza==1)
			//cprint Teve atualizacao!
						
			// Aqui devo verificar se houve att no NS do TX, se sim, atualizo o meu
			// Se nao, atualizo minha RT e incremento
			
			set etapa 3
			
			set info_repetida 0
			
			//if($meu_id==1)
				// CODIGO PARA MOSTRAR MEUS VIZINHOS ATUALIZADOS
				//cprint MEUS_VIZINHOS_ATUALIZADOS = 
				//for i 0 $n_nos
					//if($i==1)
						//tget temp1 vizinhos $i 0
						//tget temp2 vizinhos $i 1
						//tget temp3 vizinhos $i 2
						//cprint | $temp1 | $temp2 | $temp3 |
					//end
				//end
			//end
			
		else
			
			inc info_repetida
			int info_repetida $info_repetida
			
			if($info_repetida<2)
				set etapa 3
			else
				set etapa 2
			end
			
		end

end

if($meu_id==1)
	script principal_TX
else
	script principal_RX
end 