describe YetiException::ClientError do
  describe '#initialize' do
    let(:klass) { double('class') }
    let(:details) do
      {
        here: 'are',
        some: 'details'
      }
    end
    let(:http_status) { double('http status') }

    subject { described_class.new(klass, details, http_status) }

    it 'sets the attributes' do
      expect(subject.klass).to eq(klass)
      expect(subject.details).to eq(details)
      expect(subject.transient).to eq(false)
      expect(subject.http_status).to eq(http_status)
    end

    context 'when http status is omitted' do
      subject { described_class.new(klass, details) }

      it 'sets the default http status' do
        expect(subject.http_status).to eq(400)
      end
    end
  end
end
