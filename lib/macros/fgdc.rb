# frozen_string_literal: true

module Macros
  # Macros for extracting FGDC values from Nokogiri documents
  module FGDC
    def normalize_type
      extract_fgdc('/*/idinfo/citation/citeinfo/geoform', translation_map: 'types')
    end

    def harvard_uuid(record)
      urls = record.xpath('/*/idinfo/citation/citeinfo/onlink', TrajectPlus::Macros::FGDC::NS).map(&:text)
      urls.first.split('CollName=')[1]
    end

    def extract_uuid(record, context)
      institution = context.settings.fetch('agg_provider')
      if institution.include?('Harvard')
        harvard_uuid(record)
      else
        record.xpath('/*/spdoinfo/ptvctinf/sdtsterm/@Name').map(&:text)
      end
    end

    def generate_fgdc_id(prefixed: false)
      lambda { |record, accumulator, context|
        identifier = select_identifier(record, context)

        next if identifier.blank?

        accumulator << if prefixed
                         identifier_with_prefix(context, identifier)
                       else
                         identifier
                       end
      }
    end

    def select_identifier(record, context)
      uuid = extract_uuid(record, context)
      uuid.presence || default_identifier(context)
    end
  end
end
