class RegistrationsController < Devise::RegistrationsController
  def create
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email, :password, :first_name, :last_name
    ])

    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
      else
        expire_data_after_sign_in!
      end

      render json: { user: resource }, with_tokens: true
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: { status: "Error", error: resource.errors.full_messages.join(". ") }
    end
  end
end
