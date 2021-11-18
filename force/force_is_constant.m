function const = force_is_constant(forcename, model_type)

%force definitions based on the content of get_force_expr()

if strcmp(model_type, 'oscillator')
	const = get_force_is_const_oscillator(forcename);
else
	const = get_force_is_const_signal(forcename);
end


function const = get_force_is_const_oscillator(forcename)

	switch forcename
		case 'photo'
			const=0;
		case 'impulse'
			const=0;
		case 'hoffman'
			const=0;
		case 'sinewave'
			const=0;
		case '60'
			const=0;
		case '100'
			const=0;
		case '200'
			const=0;
		case 'cts'
			const=1;
		case 'noforce'
			const=1;
	end


function const = get_force_is_const_signal(forcename)

	switch forcename
		case 'photo'
			const=0;
		case 'impulse'
			const=0;
		case 'hoffman'
			const=0;
		case 'sinewave'
			const=0;
		case '60'
			const=0;
		case '100'
			const=0;
		case '200'
			const=0;
		case 'cts'
			const=1;
		case 'noforce'
			const=1;
end
