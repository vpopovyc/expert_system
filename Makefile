# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: vpopovyc <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2018/09/24 11:09:44 by vpopovyc          #+#    #+#              #
#    Updated: 2018/10/04 19:53:58 by vpopovyc         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all:
	swift build --configuration release --build-path build
	cp build/release/expert_system .

clean:
	rm -rf build/

fclean: clean
	rm -rf expert_system

re: fclean all

xc:
	swift package generate-xcodeproj 
