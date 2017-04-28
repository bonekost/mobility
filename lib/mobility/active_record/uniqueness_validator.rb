module Mobility
  module ActiveRecord
    class UniquenessValidator < ::ActiveRecord::Validations::UniquenessValidator
      def validate_each(record, attribute, value)
        klass = record.class
        if klass.translated_attribute_names.include?(attribute.to_s)
          return unless value.present?
          relation = klass.i18n.where(attribute => value)
          relation = relation.where.not(klass.primary_key => record.id) if record.persisted?
          relation = relation.merge(options[:conditions]) if options[:conditions]

          if relation.exists?
            error_options = options.except(:case_sensitive, :scope, :conditions)
            error_options[:value] = value

            record.errors.add(attribute, :taken, error_options)
          end
        else
          super
        end
      end
    end
  end
end
