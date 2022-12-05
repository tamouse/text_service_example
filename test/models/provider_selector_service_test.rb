# frozen_string_literal: true

class ProviderSelectorServiceTest < ActiveSupport::TestCase
  test "the service instance has all the providers" do
    service = ProviderSelectorService.new
    refute_nil service.providers
    assert_equal Provider.count, service.providers.length
  end

  test "the weighted_randomizer picks a provider" do
    service = ProviderSelectorService.new
    provider = service.weighted_randomizer
    refute_nil provider
  end

  test "let's try the weighted_randomizer a lot and see what it does" do
    skip :"As the provider's weight is no longer updated, this test no longer makes sense"
    service = ProviderSelectorService.new
    freq = Hash.new(0)
    1000.times do |_i|
      p = service.weighted_randomizer
      freq[p.id] += 1
    end
    Provider.active.find_each do |p|
      puts "p.id=#{p.id}, p.weight: #{p.weight}, freq[p.id]=#{freq[p.id]}, freq[p.id].to_f / 1000.0=#{freq[p.id].to_f / 1000.0}"
      assert_in_delta p.weight, freq[p.id].to_f / 1000.0, 0.01
    end
  end

  test "take a provider out of service" do
    inactive_provider =  Provider.where(status: Provider::STATUS_ACTIVE).sample
    inactive_provider.update(status: Provider::STATUS_INACTIVE)
    service = ProviderSelectorService.new
    provider = service.weighted_randomizer
    refute_nil provider
    refute_equal inactive_provider, provider, "Oops! inactive_provider is equal to provider"
  end

  test "take a provider out of service and run the weighted_randomizer many times" do
    skip :"As the provider's weight is no longer updated, this test no longer makes sense"
    inactive_provider =  Provider.active.sample
    inactive_provider.update(status: Provider::STATUS_INACTIVE)

    service = ProviderSelectorService.new
    freq = Hash.new(0)

    1000.times do |_i|
      p = service.weighted_randomizer
      freq[p.id] += 1
    end
    Provider.active.find_each do |p|
      puts "p.id=#{p.id}, p.weight: #{p.weight}, freq[p.id]=#{freq[p.id]}, freq[p.id].to_f / 1000.0=#{freq[p.id].to_f / 1000.0}"
      assert_in_delta p.weight, freq[p.id].to_f / 1000.0, 0.01
    end
  end

  test "all providers out of service" do
    Provider.update_all(status: Provider::STATUS_INACTIVE)

    service = ProviderSelectorService.new
    provider = service.weighted_randomizer

    assert_nil provider
  end

  test "provide an exception" do
    exception = Provider.first
    service = ProviderSelectorService.new(except: [exception.id])
    provider = service.weighted_randomizer
    refute_nil provider
    refute_equal exception.id, provider.id
  end
end
