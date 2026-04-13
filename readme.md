# lab05_oac

Laboratório 05: Implementação Monociclo do Processador RISC-V

Este repositório contém a implementação da Unidade de Controle para um processador RISC-V de ciclo único (Monociclo), desenvolvida como parte da disciplina de Organização e Arquitetura de Computadores (CIn-UFPE).
Visão Geral

O objetivo deste laboratório foi implementar o arquivo sc_control.sv, responsável por decodificar o opcode das instruções e gerar os sinais de controle necessários para o funcionamento correto do Datapath. O projeto suporta instruções do tipo R, I (Load), S (Store) e B (Branch).
Estrutura do Projeto

    rtl/: Contém os arquivos de hardware em SystemVerilog.

        sc_control.sv: Arquivo implementado com a lógica da Unidade de Controle.

        sc_datapath.sv, sc_cpu.sv, etc.: Módulos de suporte fornecidos pelos professores.

    sim/: Ambiente de simulação.

        program.hex: Código de máquina com 18 instruções de teste.

        data.hex: Estado inicial da memória de dados.

        golden.txt: Arquivo de referência para validação automática (Gabarito).

    README.md: Este guia.