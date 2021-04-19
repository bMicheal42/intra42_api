start:
		ruby ex00/ex00.rb
		ruby ex01/ex01.rb $$LOGIN
		ruby ex02/ex02.rb $$LOGIN
		ruby ex03/ex03.rb $$CAMPUS $$MONTH $$YEAR
		ruby ex04/ex04.rb $$CAMPUS $$PROJECT $$MARK
		ruby ex05/ex05.rb $$PROJECT $$FLAG $$MARK
		ruby ex06/ex06.rb $$LOGIN
init:
		bundle install
clear:
		rm *.out

.phony: start init clear