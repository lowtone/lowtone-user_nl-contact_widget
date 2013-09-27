$ = jQuery

# ajax mode: abort
# usage: $.ajax({ mode: 'abort'[, port: 'uniqueport']});
# if mode:'abort' is used, the previous request on that port (port can be undefined) is aborted via XMLHttpRequest.abort() 

(->
	ajax = $.ajax
	pendingRequests = {}

	$.ajax = (settings) ->
		# create settings for compatibility with ajaxSetup
		
		settings = $.extend settings, $.extend({}, $.ajaxSettings, settings)

		port = settings.port

		if ('abort' == settings.mode) 
			pendingRequests[port].abort() if pendingRequests[port] 
			
			return (pendingRequests[port] = ajax.apply this, arguments)

		return ajax.apply this, arguments
)()

# provides cross-browser focusin and focusout events
# IE has native support, in other browsers, use event caputuring (neither bubbles)

# provides delegate(type: String, delegate: Selector, handler: Callback) plugin for easier event delegation
# handler is only called when $(event.target).is(delegate), in the scope of the jquery-object for event.target 

# provides triggerEvent(type: String, target: Element) to trigger delegated events

(->
	events = 
		focus: 'focusin'
		blur: 'focusout'

	callback = (original, fix) ->
		$.event.special[fix] = 
			setup: ->
				return false if $.browser.msie

				this.addEventListener original, $.event.special[fix].handler, true
			teardown: ->
				return false if $.browser.msie

				this.removeEventListener original, $.event.special[fix].handler, true
			handler: (e) ->
				arguments[0] = $.event.fix e
				arguments[0].type = fix
				
				$.event.handle.apply this, arguments

	$.each events, callback

	$.extend $.fn, 
		delegate: (type, delegate, handler) ->
			this.bind type, (event) ->
				target = $ event.target
				
				handler.apply target, arguments if target.is delegate
		triggerEvent: (type, target) ->
			this.triggerHandler type, [$.event.fix {type: type, target: target}]
)()

# Sensible part starts

_sendible_params = {}

default_params = 
	labels: 
		first_name: 'First name'
		last_name: 'Last name'
		email: 'E-mail'
		gender: 'Gender'
		company: 'Company'
		occupation: 'Occupation'
		telephone: 'Telephone'
		mobile: 'Mobile'
		fax: 'Fax'
		address1: 'Address 1'
		address2: 'Address 2'
		city: 'City'
		country: 'Country'
		state: 'State'
		zipcode: 'Zip/Postcode'
		months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
		validate: 
			first_name:
				required: 'Please enter your first name.'
				minlength: 'Enter at least {0} characters.'
			last_name:
				required: 'Please enter your last name.'
				minlength: 'Enter at least {0} characters.'
			email:
				required: 'Please enter your email.'
				email: 'Please enter a valid email address.'
			birthday:
				required: 'Please select your birthday.'
			birthmonth:
				required: 'Please select your birthday month.'
			birthyear:
				required: 'Please select your birthday year.'

$ ->
	$('#snd_form').validate
		rules:
			first_name:
				required: true
				minlength: 2

			last_name:
				required: true

			email:
				required: true
				email: true

			birthday:
				required: true

			birthmonth:
				required: true

			birthyear:
				required: true

		messages:
			first_name:
				required: _sendible_params.labels.validate.first_name.required
				minlength: jQuery.format _sendible_params.labels.validate.first_name.minlength

			last_name:
				required: _sendible_params.labels.validate.last_name.required
				minlength: jQuery.format _sendible_params.labels.validate.last_name.minlength

			email:
				required: _sendible_params.labels.validate.email.required
				email: _sendible_params.labels.validate.email.email

			birthday:
				required: _sendible_params.labels.validate.birthday.required

			birthmonth:
				required: _sendible_params.labels.validate.birthmonth.required

			birthyear:
				required: _sendible_params.labels.validate.birthyear.required

		errorLabelContainer: '#snd_errors'

window.user_nl = (->
	new_contact_form: (params) ->
		params = $.extend null, default_params, params

		_sendible_params = params

		button_text = 'Submit'
		button_text = params.button_text if params.button_text?
		
		document.writeln '<style>'
		document.writeln '#snd_form #snd_tbl{float:left;width:100%}#snd_form #snd_row{float:left;display:block;width:100%;padding:5px}#snd_form #snd_label{float:left;width:30%}#snd_form #snd_data{float:left;width:70%}#snd_form #snd_data .prefs{width:100%}#snd_form #snd_data input{width:100%}#snd_form #snd_data .error{border:1px dotted red}#snd_form #snd_buttons{float:left;width:70%}#snd_form #snd_buttons input{width:120px}#snd_form #snd_errors{float:left;color:red;width:250px}#snd_form #snd_errors .error{float:none;display:block;clear:both;width:auto}'
		document.writeln '</style>'
		document.writeln '<div id="snd_tbl">'
		
		action = if params.is_dev then 'http://localhost:59608/Messaging.svc/CreateContact' else 'http://sendible.com/api/v1/widget-signup'
		
		document.writeln '<form id="snd_form" method="POST" action="' + action + '">'
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.first_name + '<span class="snd_required">*</span></div><div id="snd_data"><input type="text" name="first_name" class="required" title="Please enter your first name."/></div></div>'
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.last_name + '<span class="snd_required">*</span></div><div id="snd_data"><input type="text" name="last_name" class="required" title="Please enter your last name."/></div></div>'
		document.writeln '<div id="snd_row" ><div id="snd_label">' + params.labels.email + '<span class="snd_required">*</span></div><div id="snd_data"><input type="text" name="email" class="required email" title="Please enter your email."/></div></div>'  unless params.hide_email?
		
		params.allow_duplicates = 0 unless params.allow_duplicates?
		
		document.writeln '<input type="hidden" name="success_redirect" value="' + params.success_url + '"/>'
		document.writeln '<input type="hidden" name="failure_redirect" value="' + params.failure_url + '"/>'
		document.writeln '<input type="hidden" name="location" value="' + window.location + '"/>'
		document.writeln '<input type="hidden" name="allow_duplicates" value="' + params.allow_duplicates + '"/>'
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.gender + '<span class="snd_required">*</span></div><div id="snd_data"><select name="gender" title="Please select your gender." class="required"><option value=""></option><option value="male">Male</option><option value="female">Female</option></select></div></div>'  if params.show_gender
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.company + '</div><div id="snd_data"><input type="text" name="company" title="Please enter your company name.(optional)"/></div></div>' if params.show_company
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.occupation + '</div id="snd_data"><div id="snd_data"><input type="text" name="occupation" title="Please enter your occupation.(optional)"/></div></div>' if params.show_occupation
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.telephone + '</div id="snd_data"><div id="snd_data"><input type="text" name="telephone" title="Please enter your home/work landline number.(optional)"/></div></div>' if params.show_telephone
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.mobile + '</div><div id="snd_data"><input type="text" name="mobile" title="Please enter your mobile number. Include country prefix. e.g. +1, +44 etc.(optional)"/></div></div>' if params.show_mobile
		document.writeln '<div id="snd_row" ><div id="snd_label">' + params.labels.fax + '</div><div id="snd_data"><input type="text" name="fax" title="Please enter your fax number. (optional)"/></div></div>' if params.show_fax
		
		if params.show_address
			document.writeln '<div id="snd_row" ><div id="snd_label">' + params.labels.address1 + '</div><div id="snd_data"><input type="text" name="address1" title="Please enter your address. (optional)"/></div></div>'
			document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.address2 + '</div><div id="snd_data"><input type="text" name="address2" /></div></div>'
			document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.city + '</div><div id="snd_data"><input type="text" name="city" /></div></div>'
			document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.country + '</div><div id="snd_data"><input type="text" name="country" /></div></div>'
			document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.state + '</div><div id="snd_data"><input type="text" name="state" maxlength="2" /></div></div>'
			
			params.show_zip = true if not params.show_zip? or params.show_zip is false
		
		document.writeln '<div id="snd_row"><div id="snd_label">' + params.labels.zipcode + '</div><div id="snd_data"><input type="text" name="postcode" /></div></div>' if params.show_zip? and params.show_zip
		
		if params.show_birthday
			days = ''
			years = ''
			i = 1

			while i <= 31
				days += '<option value="' + i + '">' + i + '</option>'
				i++

			year = new Date().getFullYear()

			i = year

			while i > year - 100
				years += '<option value="' + i + '">' + i + '</option>'
				i--

			months = '<option value="1">' + params.labels.months[0] + '</option><option value="2">' + params.labels.months[1] + '</option><option value="3">March</option><option value="4">April</option><option value="5">May</option><option value="6">June</option><option value="7">July</option><option value="8">August</option><option value="9">September</option><option value="10">October</option><option value="11">November</option><option value="12">December</option>'
			
			document.writeln '<div id="snd_row" ><div id="snd_label">Birthday*</div><div id="snd_data"><select name="birthday" id="birthday"><option value="">Day</option>' + days + '</select><select name="birthmonth" id="birthmonth"><option value="">Month</option>' + months + '</select><select name="birthyear" id="birthyear"><option value="">Year</option>' + years + '</select></div></div>'
		
		if params.custom?
			customParams = params.custom
			
			document.writeln '<input type="hidden" name="custom_field_count" value="' + customParams.length + '"/>'
			
			i = 0

			while i < customParams.length
				className = ''
				className = 'required'  if customParams[i].required? and customParams[i].required is true
				customParams[i].field_title = customParams[i].field_name  unless customParams[i].field_title?
				
				if className is 'required'
					document.writeln '<div id="snd_row" ><div id="snd_label">' + decodeURIComponent(customParams[i].field_title) + '<span class="snd_required">*</span></div><div id="snd_data">'
				else
					document.writeln '<div id="snd_row" ><div id="snd_label">' + decodeURIComponent(customParams[i].field_title) + '</div><div id="snd_data">'
				
				document.writeln '<input type="hidden" name="custom_' + i + '_name" value="' + customParams[i].field_name.toLowerCase() + '"/>'
				document.writeln '<input type="hidden" name="custom_' + i + '_type" value="' + customParams[i].field_type.toLowerCase() + '"/>'
				
				if customParams[i].field_type is 'password'
					document.writeln '<input type="password" class="' + className + '" name="' + customParams[i].field_name.toLowerCase() + '" title="Please enter your ' + customParams[i].field_title.toLowerCase() + '. "/>'
				
				#else if (customParams[i].field_type == 'date') {
				#			document.writeln('<input type="text" class="'+className+' date" name="'+customParams[i].field_name.toLowerCase()+'" title="Please enter a valid date. " value=""/>');
				#		 }
				
				else if customParams[i].field_type is 'date'
					document.writeln '<input type="hidden" name="' + customParams[i].field_name.toLowerCase() + '" id="custom_' + i + '"  ">'
					onchangeString = 'jQuery('#custom_' + i + '').val(jQuery('#custom_' + i + '_field1').val() + ' ' + jQuery('#custom_' + i + '_field2').val() + ' ' + jQuery('#custom_' + i + '_field3').val());'
					document.writeln '<select id="custom_' + i + '_field1" class="' + className + '" title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " onchange="' + onchangeString + '">'
					document.writeln '<option value=""></option>'
					currentDate = new Date().getDate()
					d = 1

					while d <= 31
						day = d.toString()
						
						document.writeln '<option value="' + day + '" ' + (if currentDate == d then 'selected="selected"' else '') + '>' + day + '</option>'
						
						d++

					document.writeln '</select>'
					document.writeln '<select title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " id="custom_' + i + '_field2" class="' + className + '" onchange="' + onchangeString + '">'
					document.writeln '<option value=""></option>'
					
					currentMonth = new Date().getMonth()

					for month, i in params.labels.months
						document.writeln '<option value="' + month + '" ' + (if currentMonth == i then 'selected="selected"' else '') + '>' + month + '</option>'

					document.writeln '</select>'
					document.writeln '<select title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " id="custom_' + i + '_field3" class="' + className + '" onchange="' + onchangeString + '">'
					document.writeln '<option value=""></option>'
					
					currentYear = new Date().getFullYear()
					y = currentYear - 100

					while y < currentYear + 100
						yr = y.toString()
						
						document.writeln '<option value="' + yr + '" ' + (if currentYear == y then 'selected="selected"' else '') + '>' + yr + '</option>'

						y++

					document.writeln '</select>'
				
				else if customParams[i].field_type is 'time'
					document.writeln '<input type="hidden" name="' + customParams[i].field_name.toLowerCase() + '" id="custom_' + i + '"  ">'
					
					onchangeString = 'jQuery('#custom_' + i + '').val(jQuery('#custom_' + i + '_field1').val() + ':' + jQuery('#custom_' + i + '_field2').val() + ' ' + jQuery('#custom_' + i + '_field3').val());'
					
					document.writeln '<select title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " id="custom_' + i + '_field1" class="' + className + '" onchange="' + onchangeString + '">'
					document.writeln '<option value=""></option>'
					
					h = 1

					while h <= 12
						hour = h.toString()
						hour = '0' + hour  if h < 10
						document.writeln '<option value="' + hour + '">' + hour + '</option>'
						h++
					
					document.writeln '</select>'
					document.writeln ':'
					document.writeln '<select title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " id="custom_' + i + '_field2" class="' + className + '" onchange="' + onchangeString + '">'
					document.writeln '<option value=""></option>'
					
					m = 0

					while m < 60
						minute = m.toString()
						minute = '0' + minute  if m < 10
						document.writeln '<option value="' + minute + '">' + minute + '</option>'
						m++
					
					document.writeln '</select>'
					document.writeln '<select title="Please select the ' + customParams[i].field_title.toLowerCase() + '. " id="custom_' + i + '_field3" class="' + className + '" onchange="' + onchangeString + '"><option value=""></option><option value="AM">AM</option><option value="PM">PM</option></select>'
				
				else if customParams[i].field_type is 'url'
					document.writeln '<input type="text" class="' + className + ' url" name="' + customParams[i].field_name.toLowerCase() + '" title="Please enter a valid ' + customParams[i].field_title.toLowerCase() + ' URL. " value="YYYY-mm-dd"/>'
				
				else if customParams[i].field_type is 'numeric'
					document.writeln '<input type="text" class="' + className + ' number" name="' + customParams[i].field_name.toLowerCase() + '" title="Please enter a valid ' + customParams[i].field_title.toLowerCase() + '. " value=""/>'
				
				else if customParams[i].field_type is 'list'
					if customParams[i].field_options? and customParams[i].field_options isnt ''
						customParams[i].field_options = decodeURIComponent(customParams[i].field_options)
						options = customParams[i].field_options.split('|')
						optionsSelect = '<select class="' + className + '" name="' + customParams[i].field_name.toLowerCase() + '" title="Please select your ' + customParams[i].field_title.toLowerCase() + '. ">'
						o = 0

						while o < options.length
							optionsSelect = optionsSelect + '<option value="' + options[o] + '">' + options[o] + '</option>'
							o++
						optionsSelect = optionsSelect + '</select>'
						document.writeln optionsSelect
				
				else if customParams[i].field_type is 'textarea'
					document.writeln '<textarea class="' + className + '" name="' + customParams[i].field_name.toLowerCase() + '" title="Please enter your ' + customParams[i].field_title.toLowerCase() + '. "></textarea>'
				
				else
					document.writeln '<input type="text" class="' + className + '" name="' + customParams[i].field_name.toLowerCase() + '" title="Please enter your ' + customParams[i].field_title.toLowerCase() + '. "/>'
				
				document.writeln '</div></div>'
				
				i++
		
		document.writeln '<div id="snd_row" ><div id="snd_label">Preferred Contact Method</div><div id="snd_data"><select class="prefs" name="preference" id="preference"><option value="Email">Email</option><option value="SMS">SMS</option></select></div></div>'  if params.show_mobile
		
		params.group_id = -1  unless params.group_id?
		params.notify_group_id = -1  unless params.notify_group_id?
		params.notify_message = ''  unless params.notify_message?
		
		params.notify_emails is ''  unless params.notify_emails?
		
		document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="notify_group_id" value="' + params.notify_group_id.toString() + '" /></div>'
		document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="notify_message" value="' + params.notify_message.toString() + '" /></div>'
		
		unless params.notify_emails?
			document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="notify_emails" value="" /></div>'
		else
			document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="notify_emails" value="' + params.notify_emails.toString() + '" /></div>'
		
		document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="group_id" value="' + params.group_id.toString() + '" /></div>'
		document.writeln '<div id="snd_row" style="display:none;"><input type="hidden" name="api_key" value="' + params.api_key + '" /></div>'
		document.writeln '<div id="snd_row" class="snd_btn_row" ><div id="snd_label">&nbsp;</div><div id="snd_buttons"><input type="submit"  name="snd_submit" value="' + button_text + '" /></div></div>'
		
		unless params.is_wl is true
			trackingCode = ''
			trackingCode = '?f=' + params.tracking_code  if params.tracking_code?
		
		# document.writeln('<div id="snd_row" class="snd_logo_row" ><div id="snd_label">&nbsp;</div><div id="snd_buttons">Powered by <a href="http://www.sendible.com' + trackingCode + '" target="_blank" title="Powered by Sendible.com - Social Media Management for Small Businesses.">Sendible</a></div></div>');
		document.writeln '<div id="snd_row" ><div id="snd_label">&nbsp;</div><div id="snd_errors"></div></div>'
		document.writeln '</form>'
		document.writeln '</div>'
)()