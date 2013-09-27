<?php
/*
 * Plugin Name: User.nl Contact Widget
 * Plugin URI: http://wordpress.lowtone.nl/plugins/user_nl-contact_widget/
 * Description: Create a User.nl contact widget using a shortcode or WordPress widget.
 * Version: 1.0
 * Author: Lowtone <info@lowtone.nl>
 * Author URI: http://lowtone.nl
 * License: http://wordpress.lowtone.nl/license
 */
/**
 * @author Paul van der Meijs <code@lowtone.nl>
 * @copyright Copyright (c) 2013, Paul van der Meijs
 * @license http://wordpress.lowtone.nl/license/
 * @version 1.0
 * @package wordpress\plugins\lowtone\user_nl\contact_widget
 */

namespace lowtone\user_nl\contact_widget {

	use lowtone\content\packages\Package,
		lowtone\ui\forms\Form,
		lowtone\ui\forms\Input,
		lowtone\ui\forms\FieldSet,
		lowtone\wp\widgets\simple\Widget;

	// Includes
	
	if (!include_once WP_PLUGIN_DIR . "/lowtone-content/lowtone-content.php") 
		return trigger_error("Lowtone Content plugin is required", E_USER_ERROR) && false;

	// Init

	Package::init(array(
			Package::INIT_PACKAGES => array("lowtone", "lowtone\\wp"),
			// Package::INIT_MERGED_PATH => __NAMESPACE__,
			Package::INIT_SUCCESS => function() {

				// Register widget
				
				Widget::register(array(
						Widget::PROPERTY_ID => "lowtone_user_nl_contact_widget",
						Widget::PROPERTY_NAME => __("User.nl Contact Widget", "lowtone_user_nl_contact_widget"),
						Widget::PROPERTY_DESCRIPTION => __("Add a widget to subscribe to a User.nl contact group.", "lowtone_user_nl_contact_widget"),
						Widget::PROPERTY_FORM => function($instance) {
							$instance = array_merge(array(
									"custom" => array()
								), (array) $instance);

							$form = new Form();

							// Standard fields fieldset
							
							$standardFieldsFieldSet = $form
								->createFieldSet(array(
									FieldSet::PROPERTY_LEGEND => __("Standard fields", "lowtone_user_nl_contact_widget")
								))
								->appendChild(
									$form->createInput(Input::TYPE_CHECKBOX, array(
										Input::PROPERTY_LABEL => __("First name", "lowtone_user_nl_contact_widget"),
										Input::PROPERTY_SELECTED => true,
										Input::PROPERTY_DISABLED => true,
									))
								)
								->appendChild(
									$form->createInput(Input::TYPE_CHECKBOX, array(
										Input::PROPERTY_LABEL => __("Last name", "lowtone_user_nl_contact_widget"),
										Input::PROPERTY_SELECTED => true,
										Input::PROPERTY_DISABLED => true,
									))
								)
								->appendChild(
									$form->createInput(Input::TYPE_CHECKBOX, array(
										Input::PROPERTY_LABEL => __("E-mail", "lowtone_user_nl_contact_widget"),
										Input::PROPERTY_SELECTED => true,
										Input::PROPERTY_DISABLED => true,
									))
								);
							
							$standardFields = array(
									"gender" => __("Gender", "lowtone_user_nl_contact_widget"),
									"address" => __("Address", "lowtone_user_nl_contact_widget"),
									"zip" => __("Zipcode", "lowtone_user_nl_contact_widget"),
									"fax" => __("Fax", "lowtone_user_nl_contact_widget"),
									"occupation" => __("Occupation", "lowtone_user_nl_contact_widget"),
									"mobile" => __("Mobile", "lowtone_user_nl_contact_widget"),
									"telephone" => __("Telephone", "lowtone_user_nl_contact_widget"),
									"company" => __("Company", "lowtone_user_nl_contact_widget"),
									"birthday" => __("Birthday", "lowtone_user_nl_contact_widget"),
								);

							$standardFields = apply_filters("lowtone_user_nl_contact_widget_standard_fields", $standardFields);
								
							foreach ($standardFields as $name => $title) {
								$standardFieldsFieldSet->appendChild(
									$form->createInput(Input::TYPE_CHECKBOX, array(
										Input::PROPERTY_NAME => "show_" . $name,
										Input::PROPERTY_LABEL => $title,
										Input::PROPERTY_VALUE => 1
									))
								);
							}
								
							// Custom fields fieldset

							$customFieldsFieldSet = $form->createFieldSet(array(
									FieldSet::PROPERTY_LEGEND => __("Custom fields", "lowtone_user_nl_contact_widget")
								));

							foreach ($instance["custom"] as $key => $customField) {

								$customFieldForm = customFieldForm($customField);

								$customFieldForm->prefixNames("custom", $key);

								$customFieldFieldSet = $form
									->createFieldSet(array(
										FieldSet::PROPERTY_LEGEND => $customField["field_title"],
									))
									->setChildren($customFieldForm->getChildren());

								$customFieldsFieldSet->appendChild($customFieldFieldSet);

							} 

							$customFieldsFieldSet->appendChild(
									$form->createInput(Input::TYPE_BUTTON, array(
											Input::PROPERTY_VALUE => __("Add field", "lowtone_user_nl_contact_widget")
										))
								);

							// Add form children

							$form
								->appendChild(
									$form->createInput(Input::TYPE_TEXT, array(
											Input::PROPERTY_NAME => "title",
											Input::PROPERTY_LABEL => __("Title", "lowtone_user_nl_contact_widget")
										))
								)
								->appendChild(
									$form->createInput(Input::TYPE_TEXT, array(
											Input::PROPERTY_NAME => "api_key",
											Input::PROPERTY_LABEL => __("API key", "lowtone_user_nl_contact_widget")
										))
								)
								->appendChild(
									$standardFieldsFieldSet
								)
								->appendChild(
									$customFieldsFieldSet
								)
								->appendChild(
									$form
										->createFieldSet(array(
											FieldSet::PROPERTY_LEGEND => __("Contact group", "lowtone_user_nl_contact_widget")
										))
										->appendChild(
											$form->createInput(Input::TYPE_TEXT, array(
												Input::PROPERTY_NAME => "group_id",
												Input::PROPERTY_LABEL => __("Group Id", "lowtone_user_nl_contact_widget")
											))
										)
										->appendChild(
											$form->createInput(Input::TYPE_CHECKBOX, array(
												Input::PROPERTY_NAME => "allow_duplicates",
												Input::PROPERTY_LABEL => __("Allow duplicates", "lowtone_user_nl_contact_widget"),
												Input::PROPERTY_VALUE => 1
											))
										)
								)
								->appendChild(
									$form
										->createFieldSet(array(
											FieldSet::PROPERTY_LEGEND => __("Notification", "lowtone_user_nl_contact_widget")
										))
										->appendChild(
											$form->createInput(Input::TYPE_TEXT, array(
												Input::PROPERTY_NAME => "notify_emails",
												Input::PROPERTY_LABEL => __("Recipient", "lowtone_user_nl_contact_widget")
											))
										)
										->appendChild(
											$form->createInput(Input::TYPE_TEXT, array(
												Input::PROPERTY_NAME => "notify_message",
												Input::PROPERTY_LABEL => __("Message", "lowtone_user_nl_contact_widget"),
												Input::PROPERTY_MULTIPLE => true
											))
										)
								)
								->appendChild(
									$form
										->createFieldSet(array(
											FieldSet::PROPERTY_LEGEND => __("Button", "lowtone_user_nl_contact_widget")
										))
										->appendChild(
											$form->createInput(Input::TYPE_TEXT, array(
												Input::PROPERTY_NAME => "button_text",
												Input::PROPERTY_LABEL => __("Button text", "lowtone_user_nl_contact_widget")
											))
										)
								);

							return $form;
						},
						Widget::PROPERTY_WIDGET => function($args, $instance, $widget) {
							echo $args[Sidebar::PROPERTY_BEFORE_WIDGET];

							if (isset($instance["title"]) && ($title = trim($instance["title"])))
								echo $args[Sidebar::PROPERTY_BEFORE_TITLE] . apply_filters("widget_title", $title, $instance, $widget->id_base) . $args[Sidebar::PROPERTY_AFTER_TITLE];

							echo widget($instance);

							echo $args[Sidebar::PROPERTY_AFTER_WIDGET];
						}
					));

				// Register shortcode

				add_shortcode("user_nl_contact_widget", "lowtone\\user_nl\\contact_widget\\widget");

				// Register textdomain
				
				add_action("plugins_loaded", function() {
					load_plugin_textdomain("lowtone_user_nl_contact_widget", false, basename(__DIR__) . "/assets/languages");
				});

				return true;
			}
		));

	function widget($args) {
		$args = wp_parse_args($args, array(
				"api_key" => NULL,
				"button_text" => __("Sign Up", "lowtone_user_nl_contact_widget"),
				"group_id" => NULL,
				"notify_group_id" => -1,
				"notify_message" => "",
				"notify_emails" => NULL,
				"show_gender" => false,
				"show_address" => false,
				"show_zip" => false,
				"show_fax" => false,
				"show_occupation" => false,
				"show_mobile" => false,
				"show_telephone" => false,
				"show_company" => false,
				"show_birthday" => false,
				"allow_duplicates" => 0,
				"custom" => array(),
				"success_url" => NULL,
				"failure_url" => NULL,
				"is_wl" => true,
				"labels" => array(
					"first_name" => __("First name", "lowtone_user_nl_contact_widget"),
					"last_name" => __("Last name", "lowtone_user_nl_contact_widget"),
					"email" => __("E-mail", "lowtone_user_nl_contact_widget"),
					"gender" => __("Gender", "lowtone_user_nl_contact_widget"),
					"company" => __("Company", "lowtone_user_nl_contact_widget"),
					"occupation" => __("Occupation", "lowtone_user_nl_contact_widget"),
					"telephone" => __("Telephone", "lowtone_user_nl_contact_widget"),
					"mobile" => __("Mobile", "lowtone_user_nl_contact_widget"),
					"fax" => __("Fax", "lowtone_user_nl_contact_widget"),
					"address1" => __("Address 1", "lowtone_user_nl_contact_widget"),
					"address2" => __("Address 2", "lowtone_user_nl_contact_widget"),
					"city" => __("City", "lowtone_user_nl_contact_widget"),
					"country" => __("Country", "lowtone_user_nl_contact_widget"),
					"state" => __("State", "lowtone_user_nl_contact_widget"),
					"zipcode" => __("Zip/Postcode", "lowtone_user_nl_contact_widget"),
					"months" => array(
						__("January", "lowtone_user_nl_contact_widget"), 
						__("February", "lowtone_user_nl_contact_widget"), 
						__("March", "lowtone_user_nl_contact_widget"), 
						__("April", "lowtone_user_nl_contact_widget"), 
						__("May", "lowtone_user_nl_contact_widget"), 
						__("June", "lowtone_user_nl_contact_widget"), 
						__("July", "lowtone_user_nl_contact_widget"), 
						__("August", "lowtone_user_nl_contact_widget"), 
						__("September", "lowtone_user_nl_contact_widget"), 
						__("October", "lowtone_user_nl_contact_widget"), 
						__("November", "lowtone_user_nl_contact_widget"), 
						__("December", "lowtone_user_nl_contact_widget")
					),
					"validate" => array(
						"first_name" => array(
							"required" => __("Please enter your first name.", "lowtone_user_nl_contact_widget"),
							"minlength" => __("Enter at least {0} characters.", "lowtone_user_nl_contact_widget"),
						),
						"last_name" => array(
							"required" => __("Please enter your last name.", "lowtone_user_nl_contact_widget"),
							"minlength" => __("Enter at least {0} characters.", "lowtone_user_nl_contact_widget"),
						),
						"email" => array(
							"required" => __("Please enter your email.", "lowtone_user_nl_contact_widget"),
							"email" => __("Please enter a valid email address.", "lowtone_user_nl_contact_widget"),
						),
						"birthday" => array(
							"required" => __("Please select your birthday.", "lowtone_user_nl_contact_widget"),
						),
						"birthmonth" => array(
							"required" => __("Please select your birthday month.", "lowtone_user_nl_contact_widget"),
						),
						"birthyear" => array(
							"required" => __("Please select your birthday year.", "lowtone_user_nl_contact_widget"),
						),
					)
				)
			));

		return '<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.11.1/jquery.validate.js

"></script>' . 
			'<script type="text/javascript" src="' . plugins_url("/assets/scripts/jquery-user_nl.min.js", __FILE__) . '"></script>' .
			'<script type="text/javascript">' .
			'user_nl.new_contact_form(' . json_encode($args) . ');' .
			'</script>';
	}

	/**
	 * Create a custom field.
	 *
	 * Field types:
	 * - text
	 * - textarea
	 * - password
	 * - list
	 * - date
	 * - time
	 * - url
	 * - numeric
	 *	
	 * @param array $args Arguments for the custom field.
	 * @return array Returns the custom field.
	 */
	function customField($args) {
		return wp_parse_args($args, array(
				"field_title" => "",
				"required" => false,
				"field_name" => "",
				"field_type" => "text",
				"field_options" => ""
			));
	}

	/**
	 * Create a form for a custom field.
	 * @return Form Returns a Form instance for a custom field.
	 */
	function customFieldForm() {
		$form = new Form();

		$form
			->appendChild(
				$form->createInput(Input::TYPE_TEXT, array(
					Input::PROPERTY_NAME => "field_title",
					Input::PROPERTY_LABEL => __("Field title", "lowtone_user_nl_contact_widget")
				))
			)
			->appendChild(
				$form->createInput(Input::TYPE_TEXT, array(
					Input::PROPERTY_NAME => "field_name",
					Input::PROPERTY_LABEL => __("Field name", "lowtone_user_nl_contact_widget")
				))
			)
			->appendChild(
				$form->createInput(Input::TYPE_CHECKBOX, array(
					Input::PROPERTY_NAME => "required",
					Input::PROPERTY_LABEL => __("Required", "lowtone_user_nl_contact_widget"),
					Input::PROPERTY_VALUE => 1
				))
			)
			->appendChild(
				$form->createInput(Input::TYPE_SELECT, array(
					Input::PROPERTY_NAME => "field_type",
					Input::PROPERTY_LABEL => __("Field type", "lowtone_user_nl_contact_widget"),
					Input::PROPERTY_VALUE => array(
							"text",
							"textarea",
							"password",
							"list",
							"date",
							"time",
							"url",
							"numeric",
						),
					Input::PROPERTY_ALT_VALUE => array(
							__("Text", "lowtone_user_nl_contact_widget"),
							__("Textarea", "lowtone_user_nl_contact_widget"),
							__("Password", "lowtone_user_nl_contact_widget"),
							__("List", "lowtone_user_nl_contact_widget"),
							__("Date", "lowtone_user_nl_contact_widget"),
							__("Time", "lowtone_user_nl_contact_widget"),
							__("URL", "lowtone_user_nl_contact_widget"),
							__("Numeric", "lowtone_user_nl_contact_widget"),
						)
				))
			)
			->appendChild(
				$form->createInput(Input::TYPE_TEXT, array(
					Input::PROPERTY_NAME => "field_options",
					Input::PROPERTY_LABEL => __("Field options", "lowtone_user_nl_contact_widget"),
					Input::PROPERTY_MULTIPLE => true
				))
			);

		return $form;
	}

}