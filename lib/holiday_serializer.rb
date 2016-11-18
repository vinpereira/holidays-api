# Serializers
class HolidaySerializer

  def initialize(holiday)
    @holiday = holiday
  end

  def as_json(*)
    data = {
      id: @holiday.id.to_s,
      name: @holiday.name,
      date: @holiday.date,
      city: @holiday.city,
      state: @holiday.state,
      federal: @holiday.federal,
      type: @holiday.type
    }
    data[:errors] = @holiday.errors if @holiday.errors.any?
    data
  end

end
